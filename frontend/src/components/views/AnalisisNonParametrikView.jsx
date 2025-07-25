import React from 'react';
import { Card, CardContent, Grid, Box, Typography } from '@mui/material';
import useShinyDarkMode from '../../hooks/useShinyDarkMode';

const AnalisisNonparametrikView = () => {
  const {
    iframeRef,
    isDarkMode,
    handleIframeLoad,
    isReady,
    usingGlobalContext
  } = useShinyDarkMode({
    shinyOrigin: 'http://127.0.0.1:3838',
    enableLogging: false
  });

  return (
    <Box>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          {/* Header with status information */}
          <Box sx={{ mb: 2 }}>
            <Typography variant="h4" component="h1" gutterBottom>
              Analisis Non-Parametrik
            </Typography>
            <Typography variant="body1" color="text.secondary" gutterBottom>
              Analisis statistik non-parametrik menggunakan R Shiny
            </Typography>
          </Box>

          <Card>
            {/* Remove padding from CardContent so iframe fits perfectly */}
            <CardContent sx={{ p: 0, '&:last-child': { pb: 0 } }}>
              <iframe
                ref={iframeRef}
                id="shiny-iframe"
                src="http://127.0.0.1:3838"
                title="Analisis Nonparametrik - R Shiny"
                onLoad={handleIframeLoad}
                style={{
                  width: '85vw',
                  height: '85vh',
                  border: 'none',
                  display: 'block',
                  minHeight: '600px'
                }}
                loading="lazy"
                allow="fullscreen"
              />
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default AnalisisNonparametrikView;