import * as React from 'react';
import { useState, useEffect } from 'react';
import Grid from '@mui/material/Grid';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Divider from '@mui/material/Divider';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import InputAdornment from '@mui/material/InputAdornment';
import PrintIcon from '@mui/icons-material/Print';
import config from '../../config';

import StatCard from '../StatCard';
import SessionsChart from '../SessionsChart';
import PageViewsBarChart from '../PageViewsBarChart';
import CountryYearFilter from '../CountryYearFilter';

// Helper functions
function calculateStats(values) {
  const nums = Object.values(values)
    .flat()
    .map(v => parseFloat(v))
    .filter(v => !isNaN(v));

  if (nums.length === 0) return {};

  const mean = nums.reduce((a, b) => a + b, 0) / nums.length;
  const sorted = [...nums].sort((a, b) => a - b);
  const median = sorted.length % 2 === 0
    ? (sorted[sorted.length / 2 - 1] + sorted[sorted.length / 2]) / 2
    : sorted[Math.floor(sorted.length / 2)];
  const min = sorted[0];
  const max = sorted[sorted.length - 1];
  const range = max - min;
  const variance = nums.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / nums.length;
  const stdDev = Math.sqrt(variance);

  return { mean, median, min, max, range, variance, std_dev: stdDev };
}

function calculateGrowth(rawValues, yearRange) {
  if (!rawValues) return null;
  const [startYear, endYear] = yearRange.map(String);
  const startVal = parseFloat(rawValues[startYear]?.[0]);
  const endVal = parseFloat(rawValues[endYear]?.[0]);

  if (isNaN(startVal) || isNaN(endVal) || startVal === 0) return null;

  return ((endVal - startVal) / startVal) * 100;
}

export default function TahunAreaView({ stats, loading, error, country, setCountry, yearRange, setYearRange, setStats, countryCode, gasKeys, isPrintMode = false }) {
  const [countries, setCountries] = useState([]);
  const [years] = useState(Array.from({ length: 56 }, (_, i) => 1970 + i).reverse());
  const [gasTypes] = useState([
    { code: 'total', label: 'Total' },
    { code: 'co2', label: 'CO2' },
    { code: 'ch4', label: 'CH4' },
    { code: 'n2o', label: 'N2O' }
  ]);
  const [formData, setFormData] = useState({
    country: 'WLD',
    gasType: 'total',
    year: '2023',
    value: ''
  });
  const [isFormLoading, setIsFormLoading] = useState(true);

  const handlePrintRequest = () => {
    window.dispatchEvent(new CustomEvent('print:request'));
  };

  useEffect(() => {
    const fetchCountries = async () => {
      try {
        const response = await fetch(`${config.API_BASE_URL}/countries`);
        const data = await response.json();
        setCountries(data.countries || []);
      } catch (error) {
        console.error('Error fetching countries:', error);
      } finally {
        setIsFormLoading(false);
      }
    };
    fetchCountries();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    const { gasType, year, value } = formData;
    const yearStr = year.toString();
    const inputVal = parseFloat(value);
    if (isNaN(inputVal)) return;

    setStats(prevStats => {
      if (!prevStats) return prevStats;
      const updatedStats = JSON.parse(JSON.stringify(prevStats));
      if (!updatedStats[gasType]) updatedStats[gasType] = { raw_values: {} };

      const gasRaw = {
        ...(updatedStats[gasType].raw_values || {}),
        [yearStr]: [inputVal]
      };
      const gasStat = calculateStats(gasRaw);
      updatedStats[gasType] = {
        ...updatedStats[gasType],
        raw_values: gasRaw,
        ...gasStat
      };

      if (gasType !== 'total') {
        let sum = 0;
        ['co2', 'ch4', 'n2o'].forEach(gas => {
          const val = updatedStats[gas]?.raw_values?.[yearStr]?.[0];
          if (!isNaN(parseFloat(val))) {
            sum += parseFloat(val);
          }
        });

        if (!updatedStats.total) updatedStats.total = { raw_values: {} };

        const totalRaw = {
          ...(updatedStats.total.raw_values || {}),
          [yearStr]: [sum]
        };
        const totalStat = calculateStats(totalRaw);
        updatedStats.total = {
          ...updatedStats.total,
          raw_values: totalRaw,
          ...totalStat
        };
      }
      return updatedStats;
    });

    setFormData({ country: 'WLD', gasType: 'total', year: '2023', value: '' });
  };

  const statCards = gasKeys.map(({ key, title }) => {
    const stat = stats?.[key] || {};
    const endYearStr = yearRange[1].toString();
    const latestValRaw = stats?.[key]?.raw_values?.[endYearStr]?.[0];
    const latestVal = latestValRaw !== undefined ? parseFloat(latestValRaw) : null;
    let growthVal = calculateGrowth(stats?.[key]?.raw_values, yearRange);
    const value = latestVal !== null && !isNaN(latestVal)
      ? `(${endYearStr}): ${latestVal.toLocaleString('id-ID', { maximumFractionDigits: 2 })}`
      : '-';
    const interval = `${yearRange[0]} - ${yearRange[1]}`;
    let trend = 'neutral';
    if (growthVal !== null) {
      if (growthVal > 0) trend = 'up';
      else if (growthVal < 0) trend = 'down';
    }
    let chartData = [];
    if (stats && stats[key] && stats[key].raw_values) {
      chartData = Object.entries(stats[key].raw_values).map(([year, value]) => ({
        year: parseInt(year),
        value: value !== null ? Number(value) : 0,
      })).sort((a, b) => a.year - b.year);
    }
    return { title, value, interval, trend, data: chartData, details: stat, growth: growthVal, country: country };
  });

  return (
    <Box sx={{ px: { xs: 0, md: 10 } }}>
      <div id="gambaran-umum-section">
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 1, mb: 2 }}>
          <Typography component="h2" variant="h4">
            Gambaran Umum GHGE berdasarkan Tahun dan Area
          </Typography>
        </Box>
        <Divider />

        <Box id="form-section" sx={{ my: 4, p: 3, bgcolor: 'background.paper', borderRadius: 1, boxShadow: 1 }}>
          <Typography component="h2" variant="h6">Tambah/Update Data (Simulasi)</Typography>
          <Typography sx={{ mb: 2 }}>Lihat perubahan yang akan terjadi jika data diubah atau ditambahkan.</Typography>
          <form onSubmit={handleSubmit}>
            <Grid container spacing={3} columns={12}>
              <Grid item size={{ xs: 12, md: 3 }}>
                <TextField fullWidth select name="country" label="Pilih Kode Negara" value={formData.country} onChange={handleInputChange} variant="filled" disabled={isFormLoading} SelectProps={{ native: true }} InputLabelProps={{ shrink: true }}>
                  {countries.map((c) => (<option key={c.code} value={c.code}>{c.name} ({c.code})</option>))}
                </TextField>
              </Grid>
              <Grid item size={{ xs: 14, md: 3 }}>
                <TextField fullWidth select name="year" label="Pilih Tahun" value={formData.year} onChange={handleInputChange} variant="filled" disabled={isFormLoading} SelectProps={{ native: true }} InputLabelProps={{ shrink: true }}>
                  {years.map((y) => (<option key={y} value={y}>{y}</option>))}
                </TextField>
              </Grid>
              <Grid item size={{ xs: 14, md: 3 }}>
                <TextField fullWidth select name="gasType" label="Tipe Gas" value={formData.gasType} onChange={handleInputChange} variant="filled" disabled={isFormLoading} SelectProps={{ native: true }} InputLabelProps={{ shrink: true }}>
                  {gasTypes.map((g) => (<option key={g.code} value={g.code}>{g.label}</option>))}
                </TextField>
              </Grid>
              <Grid item size={{ xs: 14, md: 3 }}>
                <TextField variant="filled" label="Nilai" fullWidth value={formData.value} onChange={(e) => {
                  const val = e.target.value.replace(',', '.');
                  if (/^[0-9]*[.]?[0-9]*$/.test(val) || val === '') {
                    setFormData(prev => ({ ...prev, value: val }));
                  }
                }} inputMode="decimal" disabled={isFormLoading} InputProps={{ endAdornment: <InputAdornment position="end">MtCO2</InputAdornment> }} />
              </Grid>
              <Grid item size={{ xs: 12, md: 2 }}>
                <Button type="submit" variant="contained" color="primary" fullWidth disabled={isFormLoading}>Tambah</Button>
              </Grid>
            </Grid>
          </form>
          <Typography sx={{ mt: 2, fontStyle: 'italic', color: 'text.secondary' }}>*Perubahan hanya bersifat sementara.</Typography>
        </Box>
        <Box id="filter-section">
          <CountryYearFilter
            onCountryChange={val => val && setCountry(val)}
            onYearChange={range => setYearRange(range)}
          />
        </Box>

        <Grid id="statistik-section" container spacing={2} columns={12} sx={{ mt: 2, mb: 2 }}>
          {loading ? (
            gasKeys.map((_, index) => (
              <Grid key={index} item xs={15} lg={3}>
                <StatCard title={''} value={''} interval={''} trend={'neutral'} data={[]} details={{}} growth={undefined} country={''} loading={true} />
              </Grid>
            ))
          ) : error ? (
            <Grid item xs={15}>
              <Typography color="error">{error}</Typography>
            </Grid>
          ) : (
            statCards.map((card, index) => (
              <Grid key={index} item size={{ xs: 12, lg: 3 }}>
                <StatCard {...card} />
              </Grid>
            ))
          )}
          <Grid item size={{ xs: 12, md: 12 }}>
            <SessionsChart
              statsData={stats}
              loading={loading}
              error={error}
              yearRange={yearRange}
            />
          </Grid>
          <Grid item size={{ xs: 12, md: 12 }}>
            <PageViewsBarChart yearRange={yearRange} countryCode={countryCode} />
          </Grid>
        </Grid>
      </div>
    </Box>
  );
}