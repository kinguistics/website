MENU_HTML_FILENAME = "menu.txt";
BUTTON_SEPARATION_PX = 10;

function loadMenu() {
  $.get(MENU_HTML_FILENAME)
    .success(function(data) {
      var lines = data.split("\n");
      nButtons = 0;
      for (i=0; i < lines.length; i++) {
        line = lines[i];
        if (line.length) {
          nButtons++;
        }
      }

      menu_width = $("#menu").width();

      // minus 3 because that's the size of the border
      button_width = Math.floor(menu_width / (nButtons)) - 3;

      //shrink according to number of buttons
      button_width -= BUTTON_SEPARATION_PX;

      for (i=0; i < nButtons; i++) {
        line = lines[i];
        if (!line.length) {
          continue;
        }
        vals = line.split(",");
        text = vals[0];
        href = vals[1];

        line_div = $('<div></div>')
                    .addClass('menu-button')
                    .width(button_width)
                    .append($('<a></a>')
                             .attr("href",href)
                             .text(text));
        console.log(line_div);
        if (i != 0) {
          line_div.css("margin-left",BUTTON_SEPARATION_PX.toString()+"px");
        }
        $("#menu").append(line_div);

        /*
        line_link.setAttribute("href", href);
        line_link.text = text;

        // wrap it in a div
        line_div = document.createElement("div");
        line_div

        menu.append($(document.createElement("div")));
        */

      }
    });
};
