<?php

header ("X-XSS-Protection: 0");

// Is there any input?
if( array_key_exists( "name", $_GET ) && $_GET[ 'name' ] != NULL ) {
	// Feedback for end user
	// Get input
	$name = htmlspecialchars( $_GET[ 'name' ] );

	$html .= "<pre>Hello {$name}</pre>";
}

?>
