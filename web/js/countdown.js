/*
 * 
 * Nathan Reed, 29/04/2010
 */

var CountUi = {
	init: function() {

		this.counter_list = [];

		for(i=0; i < _rate_data.length; i++) {
			var ri = _rate_data[i];

			var ce = new CounterElement(ri.tag_name, {rate: ri.rate, start: ri.count, age: ri.age});
			this.counter_list.push(ce);
		}

		this.counter_list.each(function(e) { e.start(); });
	}

}

var CounterElement = new Class({

	initialize: function(e, params) {
		this.element = $(e);

		this.start_number = params.start;
		this.age = params.age;
		this.rate_per_sec = params.rate;

		if(!$defined(this.start_number)) {
			this.start_number = 0;
		}

		if(!$defined(this.age)) {
			this.age = 0;
		}

		if(!$defined(this.rate_per_sec)) {
			this.rate_per_sec = 1;
		}

		this.start_time = (new Date().getTime()/ 1000) - this.age;
		this.update_number();
	},

	start: function() {
		var update_delay_ms = 1000 / this.rate_per_sec;
		update_delay_ms = update_delay_ms.limit(70, 60000);

		this.update_display();
		setInterval(this.update_display.bind(this), update_delay_ms);
	},

	update_display: function() {
		this.update_number();
		if($defined(this.element)) {
			this.element.innerHTML = this.number.round().format();
		}
	},

	update_number: function() {
		var current_time = new Date().getTime() / 1000;

		this.age = current_time - this.start_time;
		this.number = this.start_number + this.age * this.rate_per_sec;
	}
});

/* from http://javascript.internet.com/text-effects/add-commas.html */
window.addEvent('load', Number.implement({ format: function() {
	number = '' + this;
	if (number.length > 3) {
		var mod = number.length % 3;
		var output = (mod > 0 ? (number.substring(0,mod)) : '');
		for (i=0 ; i < Math.floor(number.length / 3); i++) {
			if ((mod == 0) && (i == 0))
				output += number.substring(mod+ 3 * i, mod + 3 * i + 3);
			else
				output+= ',' + number.substring(mod + 3 * i, mod + 3 * i + 3);
		}

		return (output);
	} else {
		return number;
	}
}}));

window.addEvent('load', CountUi.init);