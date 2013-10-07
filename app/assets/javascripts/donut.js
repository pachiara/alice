  function donut (dataset, selector, hole_text) {
    donut_box_side  = typeof donut_box_side  !== 'undefined' ? donut_box_side : 250;
    donut_radius    = donut_box_side / 2;
    donut_font_size = typeof donut_font_size !== 'undefined' ? donut_font_size : "18px";
        
    legend_font_size     = typeof legend_font_size     !== 'undefined' ? legend_font_size     : "14px";
    legend_translate     = typeof legend_translate     !== 'undefined' ? legend_translate     : 20;
    legend_rect_side     = typeof legend_rect_side     !== 'undefined' ? legend_rect_side     : 18;
    legend_dy            = typeof legend_dy            !== 'undefined' ? legend_dy            : ".35em";
    legend_text_x        = typeof legend_text_x        !== 'undefined' ? legend_text_x        : 24;
    legend_text_y        = typeof legend_text_y        !== 'undefined' ? legend_text_y        : 9;
    legend_rows_x_column = typeof legend_rows_x_column !== 'undefined' ? legend_rows_x_column : 20;
    legend_width         = typeof legend_width         !== 'undefined' ? legend_width         : 200;
    legend_height        = typeof legend_height        !== 'undefined' ? legend_height        : donut_box_side;
    legend_padding       = typeof legend_padding       !== 'undefined' ? legend_padding       : 5;

    arc = d3.svg.arc()
      .outerRadius(donut_radius)
      .innerRadius(donut_radius - donut_radius / 2);
   
    pie = d3.layout.pie()
      .value(function(d) { return d.qta; });

    color_components = d3.scale.category20();
  
    svg = d3.select(selector).append("svg")
        .attr("width", donut_box_side)
        .attr("height", donut_box_side)
        .append("g")
          .attr("transform", "translate(" + donut_box_side / 2 + "," + donut_box_side / 2 + ")");
  
    g = svg.selectAll(".arc")
        .data(pie(dataset))
        .enter().append("g")
          .attr("class", "arc");
   
    g.append("path")
        .attr("d", arc)
        .style("fill", function(d, i) { return color_components(i); });
   
    g.append("text")
        .attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
        .attr("dy", ".5em")
        .style("text-anchor", "middle")
        .text(function(d,i) { return d.data.qta; })
           .attr("font-size", donut_font_size)
           .style("fill", "#ffffff");
  
    g.append("text")
        .attr("dy", ".5em")
        .style("text-anchor", "middle")
        .text(hole_text)
           .attr("font-size", donut_font_size)
           .style("fill", "#2F4F4F");
  
    entries = [];
    dataset.forEach(function(d) {
      entries.push(d.tipo);
    });
    color_components.domain(entries);
    
    legend_columns = Math.ceil(entries.length / legend_rows_x_column);
    legend_column_width = legend_width / legend_columns - legend_padding;
     
    legend = d3.select(selector).append("svg")
        .attr("class", "legend")
        .attr("width", legend_width)
        .attr("height", legend_height)
      .selectAll("g")
        .data(color_components.domain().slice())
      .enter().append("g")
        .attr("transform", function(d, i) {
            return "translate(" + (legend_padding + legend_column_width * Math.floor(i/legend_rows_x_column)) +"," + (i%legend_rows_x_column) * legend_translate + ")";
          });
  
    legend.append("rect")
        .attr("width", legend_rect_side)
        .attr("height", legend_rect_side)
        .style("fill", color_components);
  
    legend.append("text")
        .attr("x", legend_text_x)
        .attr("y", legend_text_y)
        .attr("dy", legend_dy)
        .attr("font-size", legend_font_size)
        .text(function(d) { return d; });
    
  }
