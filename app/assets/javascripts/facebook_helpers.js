
var userEmail = "";


function facebook_login(success_callback){
	FB.login(function(response) {
	   if (response.authResponse) {
	     console.log('Welcome!  Fetching your information.... ');
	     FB.api('/me', function(response) {
	       console.log('Good to see you, ' + response.name + '.');
	       userEmail = response.email;
	       var user = response;
	       success_callback(user);
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
	  console.log('User is logged out.');
	});
}

function facebook_share(){
	FB.ui(
	  {
	   method: 'feed',
	   name: 'The Facebook SDK for Javascript',
	   caption: 'Bringing Facebook to the desktop and mobile web',
	   description: (
	      'A small JavaScript library that allows you to harness ' +
	      'the power of Facebook, bringing the user\'s identity, ' +
	      'social graph and distribution power to your site.'
	   ),
	   link: 'https://developers.facebook.com/docs/reference/javascript/',
	   picture: 'http://www.fbrell.com/public/f8.jpg'
	  },
	  function(response) {
	    if (response && response.post_id) {
	      alert('Post was published.');
	    } else {
	      alert('Post was not published.');
	    }
	  }
	);
}
