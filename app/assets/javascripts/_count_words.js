
var countWords = function() {

  var wordCountElements = this.parentElement.getElementsByClassName('word-count');

  for (var i = wordCountElements.length - 1; i >= 0; i--) {

    /* This is super rough - removes HTML tags then splits on whitespace */
    var word_count = this.value.replace(/\<[^\>]+\>/, '').split(/\s+/).length;

    wordCountElements[i].textContent = word_count;
  };

}

var setupWordCounts = function() {

  var elements = document.getElementsByClassName('count-words')

  for (var i = elements.length - 1; i >= 0; i--) {
    elements[i].addEventListener('input', countWords);
  };

}

document.addEventListener('DOMContentLoaded', setupWordCounts);