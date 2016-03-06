class Banner
  constructor: () ->
    @greeting()
    @hint()

  greeting: () ->
    console.log '%c~\\(≧▽≦)/~, welcome to my website',
      'color: #333; font-size: 14px'

  hint: () ->
    console.log '%c1: Click the left corner to change background color.',
      'color: #333; font-size: 12px'

    console.log '%c2: Click the left logo to interact with the animation.',
      'color: #333; font-size: 12px'

    console.log '%c3: Click the right logo to switch between animations.',
      'color: #333; font-size: 12px'
      
exports = module.exports = Banner
