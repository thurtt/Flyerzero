
var userEmail = "";
var accessToken = "";


function facebook_login(success_callback){
	FB.login(function(response) {
	   if (response.authResponse) {
	     accessToken = response.authResponse.accessToken;
	     console.log(accessToken);
	     
	     //share authentication with server
	     $.get("/board/authenticateme/?v="+accessToken, function(data){
	     		     console.log(data);
	     		     success_callback();
	     });
	     
	   } else {
	     console.log('User cancelled login or did not fully authorize.');
	     alert("You have to authorize Flyer Zero Mobile on facebook to submit a flyer!");
	   }
	 });
}


function facebook_logout(){
	FB.logout(function(response) {
	  // user is now logged out
	  //share authentication with server
	  $.get("/board/deauthenticateme/", function(data){
	     		     console.log(data);
	     		     location.href='/'; //reload page with authenticated status.
	     });
	});
}

function facebook_share(flyer_id){
	FB.ui(
	  {
	   method: 'feed',
	   name: '',
	   caption: '',
	   description: '',
	   link: 'https://www.flyerzero.com/item/?event_id' + flyer_id,
	   picture: ''
	  },
	  function(response) {
	    if (response && response.post_id) {
	      alert('Post was published.');
	    } 
	  }
	);
}
