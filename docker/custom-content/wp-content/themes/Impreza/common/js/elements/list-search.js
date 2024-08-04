/**
 * UpSolution Element: List Search
 */
! function( $, undefined ) {
	"use strict";

	const ENTER_KEY_CODE = 13;

	/**
	 * @class usListSearch - Functionality for the List Search element.
	 * @param {String} container The container.
	 * @param {{}} options The options [optional].
	 */
	function usListSearch( container ) {
		let self = this;

		/**
		 * @var {{}} Bondable events.
		 */
		self._events = {
			changedSearchText: self._changedSearchText.bind( self ),
			sendForm: self._sendForm.bind( self ),
		};

		// Elements
		self.$container = $( container );
		self.$input = $( 'input', container );
		self.$pageContent = $( 'main#page-content' );
		self.$message = $( '.w-search-message', container );

		// Variables
		self.name = self.$input.attr( 'name' );
		self.lastValue = '';

		// Events
		self.$container
			.on( 'input', 'input', $ush.throttle( self._events.changedSearchText, /* wait */300, /* no_trailing */false ) )
			.on( 'click', 'buttom', self._events.changedSearchText )
			.on( 'submit', 'form', self._events.sendForm );

		// Defines enter presses in field
		$us.$document.on( 'keypress', function( e ) {
			if ( self.$input.is( ':focus' ) && e.keyCode === ENTER_KEY_CODE ) {
				e.preventDefault();
				self._events.changedSearchText( e );
			}
		});
	}

	// List Search API
	$.extend( usListSearch.prototype, {

		/**
		 * @event handler
		 * @param {Event} e The Event interface represents an event which takes place in the DOM.
		 */
		_sendForm: function( e ) {
			e.preventDefault();
			this._events.changedSearchText( e );
		},

		/**
		 * @event handler
		 * @param {Event} e The Event interface represents an event which takes place in the DOM.
		 */
		_changedSearchText: function( e ) {
			let self = this,
				$firstList = $( `
					.w-grid.us_post_list:not(.for_current_wp_query):not(.pagination_numbered):first:visible,
					.w-grid.us_product_list:not(.for_current_wp_query):not(.pagination_numbered):first:visible
				`, self.$pageContent );

			if ( $firstList.length ) {
				self.$message.addClass( 'hidden' ).text('');
				$firstList.addClass( 'used_by_list_search' )
			} else {
				self.$message
					.html( 'No suitable list found. Add <b>Post List</b> or <b>Product List</b> elements.' ) // do not need to translate
					.removeClass( 'hidden' );
			}
			if ( e.type === 'input' && ! self.$container.hasClass( 'live_search' ) ) {
				return;
			}
			let value = self.$input.val();
			if ( value === self.lastValue || ! self.name ) {
				return;
			}
			self.lastValue = value;
			$firstList.trigger( 'usListSearch', [ value, self.name ] );
		}

	} );

	$.fn.usListSearch = function( options ) {
		return this.each( function() {
			$( this ).data( 'usListSearch', new usListSearch( this, options ) );
		} );
	};

	$( function() {
		$( '.w-search.for_list' ).usListSearch();
	} );

}( jQuery );
