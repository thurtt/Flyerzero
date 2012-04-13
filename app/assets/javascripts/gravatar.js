/* gravatar integration stuff CLIENT SIDE */

function loadTwitter( twitter_name ){

	    new TWTR.Widget({
		  version: 2,
		  type: 'profile',
		  rpp: 2,
		  interval: 30000,
		  width: '100%',
		  height: 100,
		  theme: {
		    shell: {
		      background: 'transparent',
		      color: '#888'
		    },
		    tweets: {
		      background: 'white',
		      color: '#555555',
		      links: '#eb7d07'
		    }
		  },
		  features: {
		    scrollbar: false,
		    loop: false,
		    live: true,
		    behavior: 'all'
		  }
		}).render().setUser(twitter_name).start();
}
function loadProfile( profile ){
	
	if ( profile == '"User not found"' )
		return;
	
	for ( x in profile.entry[0].accounts ){
		if (  profile.entry[0].accounts[x].domain == "twitter.com" ) {
			twitter_name = profile.entry[0].accounts[x].username;
			//enableProfile( profile.entry[0].hash ); //<-- add function to display/reveal profile, if you want.
			loadTwitter( twitter_name );
		}
	}
	if (profile.entry[0].name.givenName || profile.entry[0].name.familyName){
		//name = ''
		if (profile.entry[0].name.givenName)
			name += profile.entry[0].name.givenName;
		if (profile.entry[0].name.familyName)
			name += profile.entry[0].name.familyName;
		updateName( profile );
	}
}

function updateName( profile ) {
    document.title += ' - ' + profile.entry[0].name.givenName + " " + profile.entry[0].name.familyName;
    //document.getElementById(profile.entry[0].hash + '_name').innerHTML = profile.entry[0].name.givenName + " " + profile.entry[0].name.familyName;
    
}
