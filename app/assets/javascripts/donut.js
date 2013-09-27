  function donut (dataset, selector, hole_text) {
    pie = d3.layout.pie()
      .value(function(d) { return d.qta; });

    color_components = d3.scale.category20();
  
    svg = d3.select(selector).append("svg")
        .attr("width", width/2)
        .attr("height", height)
        .append("g")
          .attr("transform", "translate(" + width / 4 + "," + height / 2 + ")");
  
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
  
    tipi = [];
    dataset.forEach(function(d) {
      tipi.push(d.tipo);
    });
    color_components.domain(tipi);
     
    legend = d3.select(selector).append("svg")
        .attr("class", "legend")
        .attr("width", legend_width)
        .attr("height", height)
      .selectAll("g")
        .data(color_components.domain().slice())
      .enter().append("g")
        .attr("transform", function(d, i) { return "translate(0," + i * legend_translate + ")"; });
  
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
