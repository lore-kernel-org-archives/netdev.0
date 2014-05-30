From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH v2 net-next 3/8] net: cdc_ncm: inform usbnet when rx
 buffers are reduced
Date: Fri, 30 May 2014 12:42:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17250700@AcuExch.aculab.com>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
	<1401435070-26721-4-git-send-email-bjorn@mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D1725057A@AcuExch.aculab.com>
 <87d2eva41t.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
To: =?utf-8?B?J0Jqw7hybiBNb3JrJw==?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87d2eva41t.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RnJvbTogQmrDuHJuIE1vcmsNCi4uLg0KPiA+IFNpbmNlIHlvdSBhcmUgbm93IGNvcHlpbmcgdGhl
IGRhdGEgb3V0IG9mIHRoZSBVUkIncyBza2IgYmVmb3JlDQo+ID4gcGFzc2luZyB0aGUgZXRoZXJu
ZXQgcGFja2V0IHVwc3RyZWFtLCBpcyB0aGVyZSBldmVyIGFueSByZWFsDQo+ID4gcmVxdWlyZW1l
bnQgdG8gdXNlIGEgc21hbGwgcnhfbWF4PyBvciBldmVyIGNoYW5nZSByeF9tYXg/DQo+IA0KPiBZ
ZXMuICB1c2JuZXQgZG9lc24ndCBjdXJyZW50bHkgcmVjeWNsZSBza2JzLiAgQ29udGludW91c2x5
IGFsbG9jYXRpbmcgMzINCj4ga0Igc2ticyAob3IgZXZlbiA2NCBrQiB0cnVlc2l6ZSwgd2hpY2gg
aXMgdGhlIGN1cnJlbnQgY2RjX25jbSB3b3JzdA0KPiBjYXNlKSBvbiBtZW1vcnkgY29uc3RyYWlu
ZWQgaG9zdHMgaXMgYm91bmQgdG8gZmFpbCBldmVudHVhbGx5Lg0KDQpHZXR0aW5nIHVzYm5ldCB0
byByZWN5Y2xlIHNrYiBzaG91bGRuJ3QgYmUgdG9vIGhhcmQgLSBhbmQgd2lsbA0KYmUgYW4gaW1t
ZWRpYXRlIGdhaW4gZm9yIG1vc3Qgb2YgdGhlIGRyaXZlcnMuDQpJIHRoaW5rIHRoZXkgd291bGQg
YWxsIGJlbmVmaXQgZnJvbSBjb3B5aW5nIGZyYW1lcyB0byBuZXcgc2tiLg0KDQoJRGF2aWQNCg0K
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
