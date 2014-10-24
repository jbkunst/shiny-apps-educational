/**
 * Highcharts pattern fill plugin
 */
(function() {
    var idCounter = 0,
        base = Highcharts.Renderer.prototype.color;

    Highcharts.Renderer.prototype.color = function(color, elem, prop) {
        if (color && color.pattern && prop === 'fill') {
            // SVG renderer
            if (this.box.tagName == 'svg') {
                var id = 'highcharts-pattern-'+ idCounter++;
                var pattern = this.createElement('pattern')
                        .attr({
                            id: id,
                            patternUnits: 'userSpaceOnUse',
                            width: color.width,
                            height: color.height
                        })
                        .add(this.defs),
                    image = this.image(
                        color.pattern, 0, 0, color.width, color.height
                    )
                    .add(pattern);
                return 'url(' + this.url + '#' + id + ')';

            // VML renderer
            } else {
                var markup = ['<', prop, ' type="tile" src="', color.pattern, '" />'];
                elem.appendChild(
                    document.createElement(this.prepVML(markup))
                );                
            }

        } else {
            return base.apply(this, arguments);
        }
    };    
})(); 
  
Highcharts.theme = {
  chart: {
    backgroundColor:"transparent",
    style: {
      fontFamily: "Covered By Your Grace",
      color: "#FCFCFC"
            
    },
        
  },
  plotOptions: {
    line: {
      marker: {
        enabled: false
                
      }
            
    },
    column: {
      color: "#FCFCFC"
    }
        
  },
  title: {
    style: {
      fontSize: "30px"
            
    }
        
  },
  legend: {
    enabled: false,
        
  },
  credits: {
    enabled: false,
        
  },
  xAxis: {
    labels: {
      enabled: true,
      style: {
        color: "#FFFFFF",
        fontSize: "17px",
                
      }
            
    },
    title: {
      enabled: true,
      style: {
        color: "#FFFFFF",
        fontSize: "0px"
                
      }
            
    },
        
  },
  yAxis: {
    labels: {
      enabled: true,
      style: {
        color: "#FFFFFF",
        fontSize: "20px"
                
      }
            
    },
    title: {
      enabled: true,
      style: {
        color: "#FFFFFF",
        fontSize: "20px"
                
      }
            
    },
    gridLineColor: "transparent",
        
  },
  tooltip: {
    backgroundColor: "#000000",
    style: {
      color: "#FFFFFF",
      fontSize: "25px",
      padding: "10px"
            
    }
        
  }
    
};

// Apply the theme
var highchartsOptions = Highcharts.setOptions(Highcharts.theme);
