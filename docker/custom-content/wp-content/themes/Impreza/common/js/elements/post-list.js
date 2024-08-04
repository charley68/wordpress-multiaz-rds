/**
 * UpSolution Element: Post List
 */
;( function( $ ) {
	"use strict";

	// Private variables that are used only in the context of this function, it is necessary to optimize the code.
	var _history = history;

	/**
	 * @type {String} The original URL to return after closing the popup.
	 */
	var _originalURL;

	/**
	 * @class WPostList - Functionality for the Post List element.
	 * @param {String} container The container.
	 * @param {{}} options The options.
	 */
	$us.WPostList = function( container ) {
		var self = this;

		// Private "variables"
		self.data = {
			paged: 1,
			max_num_pages: 1,
			pagination: 'none',
			ajaxUrl: $us.ajaxUrl,
			ajaxData: {
				us_ajax_list_pagination: 1,
			},
		};
		self.xhr; // XMLHttpRequests instance

		// Elements
		self.$container = $( container );
		self.$list = $( '.w-grid-list', container );
		self.$loadmore = $( '.g-loadmore', container );

		// Get element settings
		var $elmSettings = $( '.w-grid-list-json:first', container );
		if ( $elmSettings.is( '[onclick]' ) ) {
			$.extend( self.data, $elmSettings[0].onclick() || {} );
		}
		$elmSettings.remove();

		self.paginationType = $ush.toString( self.data.pagination );

		/**
		 * @var {{}} Bondable events.
		 */
		self._events = {
			addNextPage: self._addNextPage.bind( self ),
			loadPostInPopup: self._loadPostInPopup.bind( self ),
			navigationInPopup: self._navigationInPopup.bind( self ),
			openPostInPopup: self._openPostInPopup.bind( self ),
			closePostInPopup: self.closePostInPopup.bind( self ),
			usListSearch: self._usListSearch.bind( self ),
		};

		// Load posts on button click or page scroll;
		if ( self.paginationType === 'load_on_btn' ) {
			self.$loadmore.on( 'mousedown', 'button', self._events.addNextPage );

		} else if ( self.paginationType === 'load_on_scroll' ) {
			$us.waypoints.add( self.$loadmore, /* offset */'-70%', self._events.addNextPage );
		}

		// Events
		self.$container.on( 'usListSearch', self._events.usListSearch );

		// Open posts in popup
		if ( self.$container.hasClass( 'open_items_in_popup' ) ) {

			// Elements
			self.$popup = $( '.l-popup', container );
			self.$popupBox = $( '.l-popup-box', self.$popup );
			self.$popupPreloader = $( '.g-preloader', self.$popup );
			self.$popupFrame = $( '.l-popup-box-content-frame', self.$popup );
			self.$popupToPrev = $( '.l-popup-arrow.to_prev', self.$popup );
			self.$popupToNext = $( '.l-popup-arrow.to_next', self.$popup );

			$us.$body.append( self.$popup );

			// Events
			self.$list
				.on( 'click', '.w-grid-item:not(.custom-link) .w-grid-item-anchor', self._events.openPostInPopup );
			self.$popupFrame
				.on( 'load', self._events.loadPostInPopup );
			self.$popup
				.on( 'click', '.l-popup-arrow', self._events.navigationInPopup )
				.on( 'click', '.l-popup-closer, .l-popup-box', self._events.closePostInPopup );
		}
	};

	var prototype = $us.WPostList.prototype;

	// Post List API
	$.extend( prototype, {

		/**
		 * Applying the "List Search" string.
		 *
		 * @event handler
		 * @param {Event} e The Event interface represents an event which takes place in the DOM.
		 * @param {String} value The search text.
		 * @param {String} key The param name.
		 */
		_usListSearch: function( e, value, key ) {
			var self = this;
			self.data.paged = 0;
			self.data.ajaxData.list_search = $ush.toString( value );
			self.$list.html(''); // clear item list
			self.$loadmore.removeClass( 'hidden' );
			$( '.w-grid-none', self.$container ).remove();
			if ( ! $ush.isUndefined( self.xhr ) ) {
				self.xhr.abort();
			}
			self.addItems();
		},

		/**
		 * Add next page.
		 *
		 * @event handler
		 * @param {Event} e The Event interface represents an event which takes place in the DOM.
		 */
		_addNextPage: function( e ) {
			var self = this;
			if ( $ush.isUndefined( self.xhr ) ) {
				self.addItems();
			}
		},

		/**
		 * Add items to element.
		 */
		addItems: function() {
			var self = this;

			self.data.paged += 1;
			self.$loadmore.addClass( 'loading' );

			// Get request link and data
			var ajaxUrl = $ush.toString( self.data.ajaxUrl ),
				ajaxData = $ush.clone( self.data.ajaxData );

			if ( ajaxUrl.indexOf( '{num_page}' ) > -1 ) {
				ajaxUrl = ajaxUrl.replace( '{num_page}', self.data.paged );

			} else if ( ajaxData.template_vars ) {
				ajaxData.template_vars = JSON.stringify( ajaxData.template_vars ); // convert for `us_get_HTTP_POST_json()`
				ajaxData.paged = self.data.paged;
			}

			self.xhr = $.ajax( {
				type: 'post',
				url: ajaxUrl,
				cache: false,
				dataType: 'html',
				data: ajaxData,
				success: function( html ) {
					var $items = $( '.w-grid-list:first > *', html );
					if ( $items.length ) {
						if ( self.$container.hasClass( 'type_masonry' ) ) {
							self.$list
								.isotope( 'insert', $items )
								.isotope( 'reloadItems' );
						} else {
							self.$list.append( $items );
						}
						// Init animation handler for new items
						if ( self.$container.hasClass( 'with_css_animation' ) ) {
							new USAnimate( self.$list );
							$us.$window.trigger( 'scroll.waypoints' );
						}
						// Init plugins or elementts
						$ush.timeout( function() {
							$( '[data-content-height]', $items ).usCollapsibleContent();
							$( '.w-slider', $items ).wSlider();
						}, 1 );
						// Reload element settings
						var $elmSettings = $( '.w-grid-list-json:first', html );
						if ( $elmSettings.is( '[onclick]' ) ) {
							$.extend( true, self.data, $elmSettings[0].onclick() || {} );
						}
					}
					else if ( self.data.paged === 1 ) {
						self.$container.append( $( html ).filter( '.w-grid-none:first' ) );
						self.$loadmore.addClass( 'hidden' );
						return;
					}
					// After loading all posts, disable pagination
					if ( ! $items.length || self.data.paged >= self.data.max_num_pages ) {
						self.$loadmore.addClass( 'hidden' );
						return
					}
					// Add point to load the next page
					if ( self.paginationType == 'load_on_scroll' ) {
						$us.waypoints.add( self.$loadmore, /* offset */'-70%', self._events.addNextPage );
					}
					$us.$canvas.trigger( 'contentChange' );

					self.$loadmore.removeClass( 'loading' );
					delete self.xhr;
				},
				error: function() {
					self.$loadmore.removeClass( 'loading' );
					delete self.xhr;
				}
			} );
		}

	} );

	// Functionality for popup window
	$.extend( prototype, {

		/**
		 * Open post in popup.
		 *
		 * @event handler
		 * @param {Event} e The Event interface represents an event which takes place in the DOM.
		 */
		_openPostInPopup: function( e ) {
			var self = this;

			// If scripts are disabled on a given screen width, then exit
			if ( $us.$window.width() <= $us.canvasOptions.disableEffectsWidth ) {
				return;
			}

			e.stopPropagation();
			e.preventDefault();

			// Remember original page URL
			_originalURL = location.href;

			// Set post by index in the list
			self.setPostInPopup( $( e.target ).closest( '.w-grid-item' ).index() );

			// Show popup
			$us.$html.addClass( 'usoverlay_fixed' );
			self.$popup.addClass( 'active' );
			$ush.timeout( function() {
				self.$popupBox.addClass( 'show' );
			}, 25 );
		},

		/**
		 * Load post in popup.
		 *
		 * @event handler
		 */
		_loadPostInPopup: function() {
			var self = this;

			// Closing the post popup using escape
			function checkEscape( e ) {
				if ( $ush.toLowerCase( e.key ) === 'escape' && self.$popup.hasClass( 'active' ) ) {
					self.closePostInPopup();
				}
			}
			self.$container.on( 'keyup', checkEscape );

			$( 'body', self.$popupFrame.contents() )
				.one( 'keyup.usCloseLightbox', checkEscape );
		},

		/**
		 * Navigation in the post popup.
		 *
		 * @event handler
		 * @param {Event} e The Event interface represents an event which takes place in the DOM.
		 */
		_navigationInPopup: function( e ) {
			this.setPostInPopup( $( e.target ).data( 'index' ) );
		},

		/**
		 * Set post by index in the list.
		 *
		 * @param {String} url The new value.
		 */
		setPostInPopup: function( index ) {
			var self = this;

			// Get current node and url
			var $node = $( '> *:eq(' + $ush.parseInt( index ) + ')', self.$list ),
				url = $ush.toString( $( '[href]:first', $node ).attr( 'href' ) );

			// If there is no href, then exit
			if ( ! url ) {
				console.error( 'No url to loaded post' );
				return;
			}

			// Gen prev / next node
			var $prev = $node.prev( ':not(.custom-link)' ),
				$next = $node.next( ':not(.custom-link)' );

			// Pagination controls switch
			self.$popupToPrev
				.data( 'index', $prev.index() )
				.attr( 'title', $( '.post_title', $prev ).text() )
				.toggleClass( 'hidden', ! $prev.length );
			self.$popupToNext
				.data( 'index', $next.index() )
				.attr( 'title', $( '.post_title', $next ).text() )
				.toggleClass( 'hidden', ! $next.length );

			// Load post by its index
			self.$popupPreloader.show();
			self.$popupFrame
				.attr( 'src', url + ( url.indexOf( '?' ) > -1 ? '&' : '?' ) + 'us_iframe=1' );

			// Set post link in URL
			_history.replaceState( /* state */null, /* unused */null, url );
		},

		/**
		 * Close post in popup.
		 *
		 * @event handler
		 */
		closePostInPopup: function() {
			var self = this;
			self.$popupBox
				.removeClass( 'show' )
				.one( 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', function() {
					self.$popup.removeClass( 'active' );
					self.$popupFrame.attr( 'src', 'about:blank' );
					self.$popupToPrev.addClass( 'hidden' );
					self.$popupToNext.addClass( 'hidden' );
					self.$popupPreloader.show();
					$us.$html.removeClass( 'usoverlay_fixed' );
				} );

			// Restore original URL
			if ( _originalURL ) {
				_history.replaceState( /* state */null, /* unused */null, _originalURL );
			}
		}
	} );

	$.fn.wPostList = function( options ) {
		return this.each( function() {
			$( this ).data( 'WPostList', new $us.WPostList( this, options ) );
		} );
	};

	$( '.w-grid.us_post_list, .w-grid.us_product_list' ).wPostList();

} )( jQuery );
