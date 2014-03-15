window.App =
  mobile: navigator.userAgent.match(/(iPhone|iPad|iPod)/i)?
  Views: {}
  Services: {}
  dispatcher: _.extend( {}, Backbone.Events )
