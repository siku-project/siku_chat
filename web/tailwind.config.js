/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        glacier: {
          50: '#f2f8fd',
          100: '#e2f0fa',
          200: '#c6e0f3',
          300: '#a1cbe8',
          400: '#6fa8d4',
          500: '#4785bd',
          600: '#33689f',
          700: '#2b5380',
          800: '#274769',
          900: '#132a45',
          950: '#0b1a2e',
        },
      },
    },
  },
  plugins: [],
}
