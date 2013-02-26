var alldata;

$(function(){
  load_chart();
  load_pi();

  setInterval(function(){
    load_chart();
    load_pi();
  }, 1000 * 3);
});

var load_pi = function(){
  $.getJSON("/api/hist", function(obj){
    var data = [];
    for(var key in obj) {
      data.push([key, obj[key]]);
    }
    data.sort(function(a, b) { return b[1] - a[1]; });

    pi_chart = new Highcharts.Chart({
      chart: {
        renderTo: 'pi_chart',
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        marginLeft: 0
      },
      animation : false,
      title: {
        text: 'ベンダー分布'
      },
      tooltip: {
        pointFormat: '{series.name}: <b>{point.percentage}%</b>',
        percentageDecimals: 1
      },
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          dataLabels: {
            enabled: true,
            color: '#000000',
            connectorColor: '#000000',
          formatter: function() {
            return '<b>'+ this.point.name +'</b>: '+ parseInt(this.percentage) +' %';
          }
          }
        },
        series : {
          animation : false
        }
      },
      series: [{
        type: 'pie',
        name: '比率',
        data: data
      }]
    });
  });
};

var load_chart = function(){
  $.getJSON("/api/all", function(data){
    alldata = data;
    
    chart = new Highcharts.Chart({
      chart: {
        renderTo: 'container',
        zoomType: 'x',
        spacingRight: 20,
        animation: false
      },
      title: {
        text: '1分毎の端末検出数'
      },
      xAxis: {
        type: 'datetime'
        // maxZoom: 14 * 24 * 3600000, // fourteen days
        // title: {
        //   text: null
        // }
      },
      yAxis: {
        title: {
          text: '検出数'
        },
        showFirstLabel: false
      },
      tooltip: {
        // formatter: function() {
        //   var d = new Date(this.x);
        //   return d.getFullYear() + '年' + (d.getMonth()+1) + '月' + 
        //     '<br>新規登録数 '+ this.y;
        // }
      },
      legend: {
        enabled: false
      },
      plotOptions: {
        area: {
          fillColor: {
            linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1},
            stops: [
              [0, Highcharts.getOptions().colors[0]],
              [1, 'rgba(2,0,0,0)']
            ]
          },
          lineWidth: 1,
          marker: {
            enabled: false,
            states: {
              hover: {
                enabled: true,
                radius: 5
              }
            }
          },
          shadow: false,
          states: {
            hover: {
              lineWidth: 1
            }
          },
          threshold: null
        },
        series: {
          animation: false
        }
      },
      
      series: [{
        type: 'area',
        name: '検出数',
        data: data
      }]
    });
  });
};