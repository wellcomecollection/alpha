var initPublicationGraph = function () {
  var bars = document.getElementsByClassName('count-bars')[0];
  var labels = document.getElementsByClassName('count-bars-labels')[0];
  var values = document.getElementsByClassName('count-bars-values')[0];


  bars.addEventListener('mouseover', function (event) {
    var element = event.target;

    while(element !== null && !element.classList.contains('bar')) {
      element = element.parentElement;
    }

    if (element === null) {
      return;
    }

    var index = Array.prototype.indexOf.call(element.parentElement.children, element);

    var shownLabels = labels.getElementsByClassName('show');
    for (var i = shownLabels.length - 1; i >= 0; i--) {
      shownLabels[i].classList.remove('show')
    };

    var label = labels.children[index];
    label.classList.add('show')


    var shownValues = values.getElementsByClassName('show');
    for (var i = shownValues.length - 1; i >= 0; i--) {
      shownValues[i].classList.remove('show')
    };

    var value = values.children[index];
    value.classList.add('show')


  });

  bars.addEventListener('mouseout', function (event) {
    var shownLabels = labels.getElementsByClassName('show');
    for (var i = shownLabels.length - 1; i >= 0; i--) {
      shownLabels[i].classList.remove('show')
    };

    var shownValues = values.getElementsByClassName('show');
    for (var i = shownValues.length - 1; i >= 0; i--) {
      shownValues[i].classList.remove('show')
    };
  });
};
