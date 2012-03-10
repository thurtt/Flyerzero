// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function() {
	$('div.slideshow img:first').addClass('first');

	$('.slideshow').cycle({
		fx: 'shuffle',
		timeout: 3000,
		speedIn:  500
	});

	$('#add_link').click( function(){
		$('#add_panel').toggle('blind');
	});

});
