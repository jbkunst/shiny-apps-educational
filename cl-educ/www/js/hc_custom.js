Highcharts.theme = {
  chart: {
    backgroundColor:"transparent",
    style: {
      fontFamily: "Shadows Into Light",
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
    backgroundColor: "#333333",
    style: {
      color: "#FFFFFF",
      fontSize: "20px",
      padding: "10px"
            
    }
        
  }
    
};

// Apply the theme
var highchartsOptions = Highcharts.setOptions(Highcharts.theme);
