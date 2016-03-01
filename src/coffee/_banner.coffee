class Banner
  constructor: () ->
    @greeting()
    @hint()

  greeting: () ->
    console.log '%c~\\(≧▽≦)/~, welcome to my website',
      'color: #333; font-size: 14px'

  hint: () ->
    console.log '%cTry to click the left corner',
      'color: #333; font-size: 14px'
exports = module.exports = Banner
