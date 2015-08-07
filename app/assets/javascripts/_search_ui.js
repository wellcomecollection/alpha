

$(function() {

  $( ".subjects-search" ).autocomplete({
    source: function(request, response) {
      $.ajax({
          url: "/subjects_lookup.json",
          dataType: "json",
          data: {label: request.term, limit: 10},
          success: function(data) {
            response(data);
          }
      });
    }, select: function(event, ui) {
      document.location = "/subjects/" + ui.item.id;
    }
  });

  $( ".people-search" ).autocomplete({
    source: function(request, response) {
      $.ajax({
          url: "/people_lookup.json",
          dataType: "json",
          data: {name: request.term, limit: 10},
          success: function(data) {

            var terms = []

            for (var i = 0; i < data.length; i++) {
              terms.push({"label": data[i].name, "id": data[i].id})
            };

            response(terms)
          }
      });
    }, select: function(event, ui) {
      document.location = "/people/" + ui.item.id;
    }
  });

})