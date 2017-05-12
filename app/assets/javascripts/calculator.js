var hot = null;
$(document).ready(function() {
    $("#submission").hide();
    //$('#start').on('click', displaySpreadsheet)
    displaySpreadsheet();

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
        contextMenu: true,
        colWidthsArray: 500
      });
      //$('#start').hide();
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
        data: JSON.stringify({xls_data: xlsData, col_count: colCount} ),
        success: function (result){
          $("#calculatorEvaluated").html("");
          var container1 = document.getElementById('calculatorEvaluated');
          hot1 = new Handsontable(container1, {
          data: result,
          minSpareCols: 1,
          minSpareRows: 1,
          rowHeaders: true,
          colHeaders: true,
          contextMenu: true
        });
        $('.nav-tabs a[href="#2a"]').tab('show')
      }
      }).done(
        );

    }
})
