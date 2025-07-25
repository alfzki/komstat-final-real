import * as React from 'react';
import { useState, useEffect } from 'react';
import { alpha } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import AppNavbar from './components/AppNavBar';
import Header from './components/Header';
import MainGrid from './components/MainGrid';
import SideMenu from './components/SideMenu';
import AppTheme from './theme/AppTheme';
import { ShinyDarkModeProvider } from './contexts/ShinyDarkModeContext';
import {
  chartsCustomizations,
  dataGridCustomizations,
  datePickersCustomizations,
  treeViewCustomizations,
} from './theme/customizations';

const xThemeComponents = {
  ...chartsCustomizations,
  ...dataGridCustomizations,
  ...datePickersCustomizations,
  ...treeViewCustomizations,
};

const PAGE_NAMES = [
  'Home',
  'Gambaran Umum berdasarkan Tahun dan Area',
  'Gambaran Umum per Area, Tahun, dan Tipe Gas',
  'Gambaran Umum berdasarkan Tahun dan Tipe Gas',
  'Tabel Data',
  'Analisis Non Parametrik',
  'Tentang Kami',
  'Feedback',
];

export default function Dashboard(props) {
  const [activeMenuIndex, setActiveMenuIndex] = useState(0);

  useEffect(() => {
    const handleMenuSelect = (event) => {
      setActiveMenuIndex(event.detail.menuIndex);
    };

    window.addEventListener('mainmenu:select', handleMenuSelect);
    return () => {
      window.removeEventListener('mainmenu:select', handleMenuSelect);
    };
  }, []);

  return (
    <AppTheme {...props} themeComponents={xThemeComponents}>
      <CssBaseline enableColorScheme />
      <ShinyDarkModeProvider>
        <Box sx={{ display: 'flex' }}>
          <SideMenu />
          <AppNavbar />
          <Box
            component="main"
            sx={(theme) => ({
              flexGrow: 1,
              backgroundColor: theme.vars
                ? `rgba(${theme.vars.palette.background.defaultChannel} / 1)`
                : alpha(theme.palette.background.default, 1),
              overflow: 'auto',
            })}
          >
            <Stack
              spacing={2}
              sx={{
                alignItems: 'center',
                mx: 3,
                pb: 5,
                mt: { xs: 8, md: 0 },
              }}
            >
              {/* Mengirim props ke Header dan MainGrid */}
              <Header currentPageName={PAGE_NAMES[activeMenuIndex]} />
              <MainGrid activeComponentIndex={activeMenuIndex} />
            </Stack>
          </Box>
        </Box>
      </ShinyDarkModeProvider>
    </AppTheme>
  );
}