import React, { createContext, useContext, useEffect, useRef } from 'react';
import { useColorScheme } from '@mui/material/styles';

const ShinyDarkModeContext = createContext();

/**
 * Global provider for managing dark mode synchronization with Shiny apps
 * This ensures all Shiny iframes in the application receive dark mode updates
 */
export const ShinyDarkModeProvider = ({ children }) => {
  const { mode, systemMode } = useColorScheme();
  const iframeRefsRef = useRef(new Set());
  
  // Determine the resolved mode (considering system preference)
  const resolvedMode = systemMode || mode;
  const isDarkMode = resolvedMode === 'dark';

  // Register an iframe for dark mode updates
  const registerIframe = (iframeRef, origin = 'http://127.0.0.1:3838') => {
    const iframeData = { ref: iframeRef, origin };
    iframeRefsRef.current.add(iframeData);

    // Send current dark mode state to the newly registered iframe immediately if ready
    const sendWhenReady = () => {
      if (iframeRef.current && iframeRef.current.contentWindow) {
        sendDarkModeToIframe(iframeData, isDarkMode);
      } else {
        // Try again after a delay
        setTimeout(sendWhenReady, 200);
      }
    };

    // Try to send immediately, then with delays
    sendWhenReady();
    setTimeout(() => sendDarkModeToIframe(iframeData, isDarkMode), 500);
    setTimeout(() => sendDarkModeToIframe(iframeData, isDarkMode), 1000);

    // Return cleanup function
    return () => {
      iframeRefsRef.current.delete(iframeData);
    };
  };

  // Send dark mode state to a specific iframe
  const sendDarkModeToIframe = (iframeData, isDark) => {
    const iframe = iframeData.ref.current;
    if (!iframe || !iframe.contentWindow) return false;

    try {
      const message = {
        type: 'DARK_MODE',
        value: isDark,
        timestamp: Date.now(),
        source: 'react-frontend-global'
      };

      iframe.contentWindow.postMessage(message, iframeData.origin);
      return true;
    } catch (error) {
      return false;
    }
  };

  // Broadcast dark mode changes to all registered iframes
  const broadcastDarkMode = (isDark) => {
    iframeRefsRef.current.forEach(iframeData => {
      sendDarkModeToIframe(iframeData, isDark);
    });
  };

  // Effect to broadcast dark mode changes
  useEffect(() => {
    broadcastDarkMode(isDarkMode);
  }, [isDarkMode]);

  const contextValue = {
    isDarkMode,
    registerIframe,
    broadcastDarkMode
  };

  return (
    <ShinyDarkModeContext.Provider value={contextValue}>
      {children}
    </ShinyDarkModeContext.Provider>
  );
};

/**
 * Hook to access the global Shiny dark mode context
 */
export const useShinyDarkModeContext = () => {
  const context = useContext(ShinyDarkModeContext);
  if (!context) {
    throw new Error('useShinyDarkModeContext must be used within a ShinyDarkModeProvider');
  }
  return context;
};

export default ShinyDarkModeContext;
