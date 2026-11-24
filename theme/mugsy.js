(function () {
  var b = document.querySelector('header.site a.brand'); if (!b) return;
  var base = b.getAttribute('href').replace(/index\.html$/, '');
  var L = [['Start','index.html'],['Overview','Overview.html'],['Economics','Economics.html'],['Pictures','Pictures.html'],
           ['Hobbit','Hobbit.html'],['Bugs','reference/bugs.html'],['Trivia','reference/facts.html'],['Routines','maps/routines.html']];
  var n = document.querySelector('header.site nav'); var here = location.pathname.split('/').pop();
  L.forEach(function (x) {
    var a = document.createElement('a'); a.href = base + x[1]; a.textContent = x[0];
    if (x[1].split('/').pop() === here) a.setAttribute('aria-current', 'page');
    n.appendChild(a);
  });
})();
