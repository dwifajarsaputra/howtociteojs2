$(document).ready(function(){
    //hides dropdown content
    $(".citation_format").hide();

    //unhides first option content
    $("#ieee").show();

    //listen to dropdown for change
    $("#select_citation").change(function(){
        //rehide content on change
        $('.citation_format').hide();
        //unhides current item
        $('#'+$(this).val()).show();
    });

    $("#download_citation").change(function() {
        window.open( this.options[ this.selectedIndex ].value );
    });

});
