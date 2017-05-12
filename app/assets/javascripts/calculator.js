var XlsManager = function (opts = {}) {
  this.originalSheet = null;
  this.originalSheetContainerId = opts.originalSheetContainerId || "calculator";

  this.evaluateSheet = null;
  this.evaluateSheetContainerId =  opts.evaluateSheetContainerId || "calculatorEvaluated";
}

XlsManager.prototype.displayOriginalSpreadsheet = function () {
    data = Handsontable.helper.createEmptySpreadsheetData(10, 10);
    var container = document.getElementById(this.originalSheetContainerId);
    this.originalSheet = new Handsontable(container, {
      data: data,
      minSpareCols: 1,
      minSpareRows: 1,
      rowHeaders: true,
      colHeaders: true,
      contextMenu: true
    });
}

XlsManager.prototype.displayEvaluatedSpreadsheet = function (data) {
    var container = document.getElementById(this.evaluateSheetContainerId);
    this.evaluateSheet = new Handsontable(container, {
      data: data,
      minSpareCols: 1,
      minSpareRows: 1,
      rowHeaders: true,
      colHeaders: true,
      contextMenu: true
    });
}

function evaluateSpredsheet(xlsManager) {
    return function evaluateSpredsheet(e, obj) {
      var xlsData = xlsManager.originalSheet.getData();
      var colCount = xlsManager.originalSheet.countCols() - xlsManager.originalSheet.countEmptyCols();
    
      $.ajax({
        url: '/calculators',
        method: 'POST',
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({xls_data: xlsData, col_count: colCount} ),
        success: function (result) {
            $("#calculatorEvaluated").html("");
            $('.nav-tabs a[href="#2a"]').tab('show')

            xlsManager.displayEvaluatedSpreadsheet(result);
        },
        error: function (response, m) {
          var errorMesage = response.responseJSON.message;
          $("#flash").html(errorMesage);
          $("#flash").removeClass("btn-info");
          $("#flash").addClass("btn-danger")
        }
      })
    }
}

$(document).ready(function() {
    var xlsManager = new XlsManager();
    xlsManager.displayOriginalSpreadsheet();
    $("#submission").on('click', evaluateSpredsheet(xlsManager))
})
