// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "chartkick/chart.js"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

import 'bootstrap/dist/js/bootstrap'
import 'bootstrap/dist/css/bootstrap'
import "bootstrap"
import "@fortawesome/fontawesome-free/css/all"
import "../trix-editor-overrides"
import "youtube"
require("trix")
require("@rails/actiontext")
require("stylesheets/application.scss")
// require("jquery-ui-dist")
require("jquery")
require("@nathanvda/cocoon")

// $(document).on('turbolinks:load', function(){
//   $('.lesson-sortable').sortable({
//     update: function ((e, ui){
//       let item = ui.item;
//       let item_data = item.data();
//       let params = {_method: 'put'};
//       params[item_data.modelName] = {row_order_position: item.index()}
//       $.ajax({
//         type: 'POST',
//         url: item_data = updateUrl,
//         dataType: 'json',
//         data: params
//       });
//     },
//     stop: function(e, ui) {
//       console.log("stop called when finishing sort of cards");
//     }
//   });
// });

$("video").bind("contextmenu", function (){
  return false;
});
