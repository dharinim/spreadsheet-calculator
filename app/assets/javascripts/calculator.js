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

// Validate in frontend for matrix to be NxM without holes
XlsManager.prototype.validateInput = function (data) {
  var filledRows = this.originalSheet.countRows() - this.originalSheet.countEmptyRows();
  var filledColumns = this.originalSheet.countCols() - this.originalSheet.countEmptyCols();

  for (var row = 0; row < filledRows; row++) {
    for (var col = 0; col < filledColumns; col++) {
      if (data[row][col] == null) {
        return false;
      }
    }
  }

  return true;
  
}

function closeEvaluatedSpredsheet(xlsManager) {
    return function evaluateSpredsheet(e, obj) {
      var xlsData = xlsManager.originalSheet.getData();
      var colCount = xlsManager.originalSheet.countCols() - xlsManager.originalSheet.countEmptyCols();
    
      if (xlsManager.validateInput(xlsData) == true)  {
        $.ajax({
          url: '/calculators',
          method: 'POST',
          dataType: "json",
          contentType: "application/json; charset=utf-8",
          data: JSON.stringify({xls_data: xlsData, col_count: colCount} ),
          success: function (result) {
              $("#calculatorEvaluated").html("");
              $('.nav-tabs a[href="#2a"]').tab('show');

              xlsManager.displayEvaluatedSpreadsheet(result);
          },
          error: function (response, m) {
            var errorMesage = response.responseJSON.message;
            $("#flash").html(errorMesage);
            $("#flash").removeClass("btn-info");
            $("#flash").addClass("btn-danger")
          }
        })        
      } else {
            $("#flash").html("Input data not valid: any NxM matrics in xls should not be null and have holes");
            $("#flash").removeClass("btn-info");
            $("#flash").addClass("btn-danger")
      }

    }
}

$(document).ready(function() {
    var xlsManager = new XlsManager();
    xlsManager.displayOriginalSpreadsheet();
    $("#submission").on('click', closeEvaluatedSpredsheet(xlsManager));
})
