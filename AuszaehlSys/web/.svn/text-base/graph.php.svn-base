<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

function piechart ( $w, $h, $chart, $file ) {
	$im     = imagecreate($w,$h);
	$bgnd   = imagecolorallocate($im,204,204,204) ;
	$black  = imagecolorallocate($im,0,0,0) ;
	
	$sum = 0 ;
	for ( $i = 0 ; $i < count($chart) ; $i += 4 ) {
		$sum += $chart[$i] ;
	}

	if ( $sum > 0 ) {		
		$sum2 = 0 ;
		for ( $i = 0 ; $i < count($chart) ; $i += 4 ) {
			if ($chart[$i] > 0) {
				$clr = imagecolorallocate($im, 
							  255*$chart[$i+1],
							  255*$chart[$i+2],
							  255*$chart[$i+3] ) ;
				imagefilledarc($im, 
					       0.5 * imagesx($im),  0.9*imagesy($im),
					       0.8 * imagesx($im), -1.6*imagesy($im),
					       180*(1-($sum2+$chart[$i])/$sum),
					       180*(1-$sum2/$sum), 
					       $clr, IMG_ARC_PIE) ;
				imagefilledarc($im, 
					       0.5 * imagesx($im),  0.9*imagesy($im),
					       0.8 * imagesx($im), -1.6*imagesy($im),
					       180*(1-($sum2+$chart[$i])/$sum),
					       180*(1-$sum2/$sum), 
					       $black, IMG_ARC_NOFILL | IMG_ARC_EDGED);
				$sum2 += $chart[$i] ;
			}
		}
		imagefilledarc($im, 
			       0.5 * imagesx($im),  0.9*imagesy($im),
			       0.2 * imagesx($im), -0.4*imagesy($im),
			       0, 180,
			       $bgnd, IMG_ARC_PIE) ;
		imagefilledarc($im, 
			       0.5 * imagesx($im),  0.9*imagesy($im),
			       0.2 * imagesx($im), -0.4*imagesy($im),
			       0, 180,
			       $black, IMG_ARC_NOFILL) ;
	}
	imagepng($im,$file);
	imagedestroy($im);
}

function barchart ( $w, $h, $chart, $file ) {
	$im     = imagecreate($w,$h);
	$black  = imagecolorallocate($im,0,0,0) ;
	
	$sum = 0 ;
	for ( $i = 0 ; $i < count($chart) ; $i += 4 ) {
		$sum += $chart[$i] ;
	}

	if ( $sum > 0 ) {
		$sum2 = 0 ;
		for ( $i = 0 ; $i < count($chart) ; $i += 4 ) {
			$clr = imagecolorallocate($im, 
						  255*$chart[$i+1],
						  255*$chart[$i+2],
						  255*$chart[$i+3] ) ;
			imagefilledrectangle($im,
					     $sum2/$sum * (imagesx($im)-1),
					     0,
					     ($sum2+$chart[$i])/ $sum
					     * (imagesx($im)-1),
					     imagesy($im),
					     $clr) ;
			imagerectangle($im,
				       $sum2/$sum * (imagesx($im)-1),
				       0,
				       ($sum2+$chart[$i])/$sum
				       * (imagesx($im)-1),
				       imagesy($im)-1,
				       $black) ;
			$sum2 += $chart[$i] ;
		}
	}
	imagepng($im,$file);
	imagedestroy($im);
}

?>
