/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './_layouts/**/*.html',
    './_includes/**/*.html',
    './_pages/**/*.{html,md}',
    './_posts/**/*.md',
    './_til/**/*.md',
    './index.html',
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
