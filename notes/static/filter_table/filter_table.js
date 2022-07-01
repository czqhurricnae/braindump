$(document).ready(function() {
    function addRemoveClass(theRows) {
        theRows.removeClass("odd even");
        theRows.filter(":odd").addClass("odd");
        theRows.filter(":even").addClass("even");
    }

    var rows = $("table#myTable tr:not(:first-child)");

    addRemoveClass(rows);

    $("#selectField").on("change", function() {
    var selected = this.value;
    if (selected != "All") {
        var visibleRows = rows.filter("[position = " + selected + "]");
        rows.not("[position = " + selected + "]").hide();
        visibleRows.show();
        addRemoveClass(visibleRows);
    }
    else {
        rows.show();
        addRemoveClass(rows);
    }
    });
});
