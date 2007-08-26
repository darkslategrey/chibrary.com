$(function() {
  // month view: toggleable thread_lists
  $("ol.threads li.thread").click(function() {
    $(this).toggleClass('closed');
    $(this).find('ol.thread_list').toggleClass('closed');
  }).dblclick(function() {
    if ($(this).is('.closed')) {
      $('ol.threads li.thread').removeClass('closed');
      $('ol.threads li.thread ol.thread_list').removeClass('closed');
    } else {
      $('ol.threads li.thread').addClass('closed');
      $('ol.threads li.thread ol.thread_list').addClass('closed');
    }
  }).each(function(){ $(this).click(); });

  // thread view: toggleable blockquotes
  $("div.message blockquote").toggle(function() {
    // close up
    this.quote = $(this).html();
    $(this).html("---- click to show quote ----")
    $(this).toggleClass('closed');
  },function(){
    // open up
    $(this).html(this.quote)
    $(this).toggleClass('closed');
  }).each(function(){ $(this).click(); });
  // after page height changes, get back to named anchor
  if (location.hash) {
    $(location.hash).ScrollTo(0);
    $(location.hash).parent().find('blockquote.closed').each(function(){ $(this).click(); });
  }
});
