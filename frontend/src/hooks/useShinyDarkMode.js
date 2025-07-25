import { useEffect, useRef, useCallback } from 'react';
import { useShinyDarkModeContext } from '../contexts/ShinyDarkModeContext';
import config from '../config';

/**
 * Enhanced custom hook for synchronizing dark mode between React frontend and Shiny iframe
 * Uses the global ShinyDarkModeContext for centralized state management
 * 
 * @param {Object} options - Configuration options
 * @param {string} options.shinyOrigin - Shiny app origin URL (default: from config)
 * @param {number} options.loadDelay - Delay after iframe load (default: 500ms)
 * @param {boolean} options.enableLogging - Enable console logging (default: true)
 * @param {boolean} options.useGlobalContext - Use global context for centralized management (default: true)
 * 
 * @returns {Object} - Object containing iframe ref and utility functions
 */
const useShinyDarkMode = (options = {}) => {
  const {
    shinyOrigin = config.SHINY_BASE_URL,
    loadDelay = 500,
    enableLogging = false,
    useGlobalContext = true
  } = options;

  const iframeRef = useRef(null);
  const isReadyRef = useRef(false);
  const unregisterRef = useRef(null);

  // Use global context if available and enabled
  const globalContext = useGlobalContext ? (() => {
    try {
      return useShinyDarkModeContext();
    } catch (error) {
      if (enableLogging) {
        console.warn('[Shiny Dark Mode] Global context not available, using local implementation');
      }
      return null;
    }
  })() : null;

  const isDarkMode = globalContext?.isDarkMode ?? false;

  // Logging utility
  const log = useCallback((message, data = null) => {
    if (enableLogging) {
      console.log(`[Shiny Dark Mode] ${message}`, data || '');
    }
  }, [enableLogging]);

  // Function to send dark mode state to Shiny iframe
  const sendDarkModeToShiny = useCallback((isDark, immediate = false) => {
    const iframe = iframeRef.current;
    if (!iframe || !iframe.contentWindow) {
      log('Cannot send message - iframe not ready');
      return false;
    }

    try {
      const message = { 
        type: 'DARK_MODE', 
        value: isDark,
        timestamp: Date.now(),
        source: globalContext ? 'react-frontend-context' : 'react-frontend-local'
      };
      
      iframe.contentWindow.postMessage(message, shinyOrigin);
      log(`Sent dark mode message: ${isDark ? 'dark' : 'light'}`, message);
      return true;
    } catch (error) {
      log('Error sending message to Shiny:', error);
      return false;
    }
  }, [shinyOrigin, log, globalContext]);

  // Function to request current dark mode state from Shiny
  const requestShinyReady = useCallback(() => {
    const iframe = iframeRef.current;
    if (!iframe || !iframe.contentWindow) {
      return false;
    }

    try {
      const message = {
        type: 'REQUEST_READY',
        timestamp: Date.now(),
        source: globalContext ? 'react-frontend-context' : 'react-frontend-local'
      };
      
      iframe.contentWindow.postMessage(message, shinyOrigin);
      log('Requested Shiny ready state', message);
      return true;
    } catch (error) {
      log('Error requesting Shiny ready:', error);
      return false;
    }
  }, [shinyOrigin, log, globalContext]);

  // Handle iframe load event
  const handleIframeLoad = useCallback(() => {
    log('Iframe loaded, setting up communication...');
    
    // Small delay to ensure Shiny app is ready
    setTimeout(() => {
      sendDarkModeToShiny(isDarkMode, true);
      requestShinyReady();
      isReadyRef.current = true;
    }, loadDelay);
  }, [isDarkMode, sendDarkModeToShiny, requestShinyReady, loadDelay, log]);

  // Register iframe with global context when available
  useEffect(() => {
    if (globalContext && globalContext.registerIframe) {
      log('Registering iframe with global context');
      unregisterRef.current = globalContext.registerIframe(iframeRef, shinyOrigin);
      
      // Also register on iframe load for late registration
      const handleLateRegistration = () => {
        if (iframeRef.current && !unregisterRef.current) {
          log('Late registering iframe with global context');
          unregisterRef.current = globalContext.registerIframe(iframeRef, shinyOrigin);
        }
      };
      
      // Wait a bit then try to register if not already done
      const timer = setTimeout(handleLateRegistration, 1000);
      
      return () => {
        clearTimeout(timer);
        if (unregisterRef.current) {
          log('Unregistering iframe from global context');
          unregisterRef.current();
          unregisterRef.current = null;
        }
      };
    }
  }, [globalContext, shinyOrigin, log]);

  // Listen for messages from Shiny app (only when not using global context)
  useEffect(() => {
    if (globalContext) {
      // Global context handles message listening
      return;
    }

    const handleMessage = (event) => {
      // Security check: only accept messages from the trusted Shiny origin
      if (event.origin !== shinyOrigin) {
        return;
      }

      if (event.data && event.data.type === 'SHINY_READY') {
        log('Received SHINY_READY message from iframe');
        isReadyRef.current = true;
        // Send current dark mode state when Shiny is ready
        sendDarkModeToShiny(isDarkMode, true);
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, [shinyOrigin, isDarkMode, sendDarkModeToShiny, log, globalContext]);

  // Send dark mode state when mode changes (only when not using global context)
  useEffect(() => {
    if (globalContext) {
      // Global context handles dark mode updates
      return;
    }

    // Wait a bit before sending message when not using global context
    const timer = setTimeout(() => {
      if (isReadyRef.current) {
        sendDarkModeToShiny(isDarkMode);
      }
    }, 1000);

    return () => clearTimeout(timer);
  }, [isDarkMode, sendDarkModeToShiny, globalContext]);

  // Return interface
  return {
    iframeRef,
    isDarkMode,
    handleIframeLoad,
    sendDarkModeToShiny,
    requestShinyReady,
    isReady: isReadyRef.current,
    usingGlobalContext: !!globalContext
  };
};

export default useShinyDarkMode;
