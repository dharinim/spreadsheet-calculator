var hot = null;
$(document).ready(function() {
    $("#submission").hide();
    $('#start').on('click', displaySpreadsheet)
    $("#submission").on('click', evaluateSpredsheet)

    function displaySpreadsheet() {
      var data = Handsontable.helper.createEmptySpreadsheetData(10, 10);
      var container = document.getElementById('calculator');
      hot = new Handsontable(container, {
        data: data,
        minSpareCols: 1,
        minSpareRows: 1,
        rowHeaders: true,
        colHeaders: true,
        contextMenu: true
      });
      $('#start').hide();
      $("#submission").show();   
    }

    function evaluateSpredsheet(e, obj) {
      var xlsData = hot.getData();
      var colCount = hot.countCols()-hot.countEmptyCols();

      $.ajax({
        url: '/calculators',
        method: 'POST',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({xls_data: xlsData, col_count: colCount} )
      }).done(
        function (result){
          $('#calculator').hide();
          var container1 = document.getElementById('calculator1');
          hot1 = new Handsontable(container1, {
          data: result,
          minSpareCols: 1,
          minSpareRows: 1,
          rowHeaders: true,
          colHeaders: true,
          contextMenu: true
        });
      });

    }
})
