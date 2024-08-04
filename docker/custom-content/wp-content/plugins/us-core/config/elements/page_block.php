<?php defined( 'ABSPATH' ) OR die( 'This script cannot be accessed directly.' );

/**
 * Configuration for shortcode: page_block
 */

$conditional_params = us_config( 'elements_conditional_options' );

/**
 * @return array
 */
return array(
	'title' => __( 'Reusable Block', 'us' ),
	'icon' => 'far fa-square',
	// dev note: element need to be loaded directly with US Builder to provide corresponding edit links
	'usb_preload' => TRUE,
	'params' => us_set_params_weight(

		// General section
		array(
			'id' => array(
				'title' => __( 'Reusable Block', 'us' ),
				'type' => 'select',
				'hints_for' => 'us_page_block',
				'options' => us_is_elm_editing_page()
					? array( '' => '– ' . us_translate( 'None' ) . ' –' ) + us_get_posts_titles_for( 'us_page_block' )
					: array(),
				'std' => '',
				'admin_label' => TRUE,
				'usb_preview' => TRUE,
			),
			'remove_rows' => array(
				'title' => __( 'Exclude Rows and Columns', 'us' ),
				'type' => 'select',
				'options' => array(
					'' => us_translate( 'None' ),
					'1' => __( 'Inside selected Reusable Block', 'us' ),
					'parent_row' => __( 'Around this element', 'us' ),
				),
				'std' => '',
				'usb_preview' => TRUE,
			),
			'force_fullwidth_rows' => array(
				'switch_text' => __( 'Stretch content of Rows to the full width', 'us' ),
				'type' => 'switch',
				'std' => 0,
				'show_if' => array( 'remove_rows', '!=', '1' ),
				'usb_preview' => TRUE,
			),
		),

		$conditional_params
	),
);
