MENU_HTML_FILENAME = "menu.txt";
BUTTON_SEPARATION_PX = 10;

function loadMenu(activeLink) {
  // add .html if we're not at the index page
  if (activeLink != ".") {
    activeLink = activeLink + ".html"
  }

  // PULL FROM THE MENU FILE
  $.get(MENU_HTML_FILENAME)
    .success(function(data) {
      var lines = data.split("\n");

      // dump empty lines
      nButtons = 0;
      for (i=0; i < lines.length; i++) {
        line = lines[i];
        if (line.length) {
          nButtons++;
        }
      }

      // how wide should the full menu be?
      menu_width = $("#body").width();

      // minus 3 because that's the size of the border
      button_width = Math.floor(menu_width / (nButtons)) - 3;
      // and shrink according to how much space we want between
      button_width -= BUTTON_SEPARATION_PX;

      for (i=0; i < nButtons; i++) {
        line = lines[i];
        if (!line.length) {
          continue;
        }

        // extract the text and link for each button
        vals = line.split(",");
        text = vals[0];
        href = vals[1];

        // create the a element for this button
        line_a = $('<a></a>')
                  .attr("href",href)
                  .text(text);
        if (href == activeLink) {
          line_a.addClass("active");
        }

        // wrap the a element in a div
        line_div = $('<div></div>')
                    .addClass('menu-button')
                    .width(button_width)
                    .append(line_a);
        // push all the non-first buttons to the right a little bit
        if (i != 0) {
          line_div.css("margin-left",BUTTON_SEPARATION_PX.toString()+"px");
        }
        
        $("#menu").append(line_div);
      }
    });
};
