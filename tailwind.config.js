/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './lib/**/*.rb',
    './_posts/**/*.{md,markdown}',
    './_til/**/*.{md,markdown}',
    './_pages/**/*.{md,markdown,html}',
  ],
  corePlugins: {
    preflight: false,
  },
  theme: {
    extend: {
      fontFamily: {
        display: ['"Barlow Condensed"', 'Impact', 'sans-serif'],
      },
    },
  },
}
