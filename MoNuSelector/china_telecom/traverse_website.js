// The purpose of this is to show how and when events fire, considering 5 steps
// happening as follows:
//
//      1. Load URL
//      2. Load same URL, but adding an internal FRAGMENT to it
//      3. Click on an internal Link, that points to another internal FRAGMENT
//      4. Click on an external Link, that will send the page somewhere else
//      5. Close page
//

var sys = require("system"),
    page = require("webpage").create(),
    pn_pages = 0,
    numCurrentPage = 1,
    loadOk = false,
    numbers_url = "http://mall.hb.189.cn/offermallsale/beautifulNumberOnly.shtml?id=2206&channelId=10";

////////////////////////////////////////////////////////////////////////////////

page.onLoadFinished = function() {
    //console.log("page.onLoadFinished");
    var pagetext = page.plainText;
    // 先求总页数
    if (pn_pages == 0) {
        pagetext = pagetext.match('共[0-9]+页')[0].match('[0-9]+')[0];
        pn_pages = parseInt(pagetext);
        // 若本脚本被用来单求总页数
        sys.args.forEach(function(arg, i){
            if (arg.toLowerCase == "--eval-pages" ||
                arg == "-c" ) {
                phantom.exit(pn_pages);
            }
        });
    }
    console.log(pagetext);
    console.log("=== page:", numCurrentPage, "/", pn_pages, "===\n\n");

    if (numCurrentPage == pn_pages) {
        phantom.exit(pn_pages);
    }
    loadOk = true;
};

////////////////////////////////////////////////////////////////////////////////

page.open(numbers_url);
page.includeJs('http://cdn.staticfile.org/jquery/2.0.3/jquery.min.js');

loadOk = false;
var interval = setInterval("checkLoop()", 500);

function checkLoop(){
    if (!loadOk) return;
    //if (numCurrentPage == pn_pages) return;

    loadOk = false;
    page.evaluate(function(ncp) {
        jQuery("#numCurrentPage").val(ncp);
        jQuery("#queryForm1").submit();
    }, ++numCurrentPage);
}

