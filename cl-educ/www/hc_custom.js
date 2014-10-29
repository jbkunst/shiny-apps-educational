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
      padding: "0px"
            
    }
        
  }
    
};

// Apply the theme
var highchartsOptions = Highcharts.setOptions(Highcharts.theme);
