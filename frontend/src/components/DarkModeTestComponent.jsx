import React from 'react';
import { 
  Card, 
  CardContent, 
  Typography, 
  Chip, 
  Box, 
  Alert 
} from '@mui/material';
import { useColorScheme } from '@mui/material/styles';
import useShinyDarkMode from '../hooks/useShinyDarkMode';

/**
 * Test component for monitoring dark mode synchronization status
 * This component provides visual feedback about the dark mode state and communication
 */
const DarkModeTestComponent = () => {
  const { mode, systemMode } = useColorScheme();
  const {
    isDarkMode,
    isReady,
    usingGlobalContext
  } = useShinyDarkMode({
    enableLogging: true
  });

  const [localStorageValue, setLocalStorageValue] = React.useState(null);

  React.useEffect(() => {
    try {
      const stored = localStorage.getItem('komstat_dark_mode');
      setLocalStorageValue(stored);
    } catch (e) {
      setLocalStorageValue('not available');
    }
  }, [isDarkMode]);

  const resolvedMode = systemMode || mode;

  return (
    <Card sx={{ mt: 2, mb: 2 }}>
      <CardContent>
        <Typography variant="h6" gutterBottom>
          Dark Mode Status Monitor
        </Typography>
        
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 2 }}>
          <Chip 
            label={`Mode: ${resolvedMode}`}
            color={isDarkMode ? 'primary' : 'default'}
            size="small"
          />
          <Chip 
            label={isReady ? 'Shiny Ready' : 'Shiny Loading'}
            color={isReady ? 'success' : 'warning'}
            size="small"
          />
          <Chip 
            label={usingGlobalContext ? 'Global Context' : 'Local Context'}
            color={usingGlobalContext ? 'info' : 'default'}
            size="small"
          />
          <Chip 
            label={`LocalStorage: ${localStorageValue || 'none'}`}
            color={localStorageValue ? 'success' : 'default'}
            size="small"
          />
        </Box>

        <Alert 
          severity={isDarkMode ? 'info' : 'success'} 
          sx={{ fontSize: '0.875rem' }}
        >
          <Typography variant="body2">
            <strong>Current Status:</strong> {resolvedMode === 'dark' ? 'Dark' : 'Light'} mode active
            {isReady && ' • Shiny communication established'}
            {usingGlobalContext && ' • Using global context'}
            <br />
            <strong>Cross-origin support:</strong> URL parameters + localStorage fallback enabled
            <br />
            <strong>Production domains:</strong> komstat-frontend.onrender.com supported
          </Typography>
        </Alert>
      </CardContent>
    </Card>
  );
};

export default DarkModeTestComponent;
