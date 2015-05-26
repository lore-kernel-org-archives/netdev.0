From: "Christian Benvenuti (benve)" <benve-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 26 May 2015 17:55:57 +0000
Message-ID: <6CE81A2095B0024BBC77007BD04E55384265B3B5@xmb-aln-x02.cisco.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1432647280.28905.107.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432647280.28905.107.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10gT24NCj4gQmVo
YWxmIE9mIERvdWcgTGVkZm9yZA0KPiBTZW50OiBUdWVzZGF5LCBNYXkgMjYsIDIwMTUgNjozNSBB
TQ0KPiBUbzogSGFnZ2FpIEVyYW4NCj4gQ2M6IGxpbnV4LXJkbWFAdmdlci5rZXJuZWwub3JnOyBu
ZXRkZXZAdmdlci5rZXJuZWwub3JnOyBMaXJhbiBMaXNzOyBHdXkNCj4gU2hhcGlybzsgU2hhY2hh
ciBSYWluZGVsOyBZb3RhbSBLZW5uZXRoDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggdjQgZm9yLW5l
eHQgMDAvMTJdIEFkZCBuZXR3b3JrIG5hbWVzcGFjZSBzdXBwb3J0IGluIHRoZQ0KPiBSRE1BLUNN
DQoNCi4uLg0KDQo+IEkgZG9uJ3QgdGhpbmsgdGhpcyBpcyBhbiBpc3N1ZSBmb3IgdXNOSUMgYXMg
aWYgeW91DQo+IHdhbnQgbmFtZXNwYWNlIHN1cHBvcnQgdGhlcmUsIHlvdSBqdXN0IHN0YXJ0IHRo
ZSB1c2VyIHNwYWNlIGFwcCBpbiBhIGdpdmVuDQo+IG5hbWVzcGFjZSBhbmQgeW91IGFyZSBwcm9i
YWJseSA5MCUgb2YgdGhlIHdheSB0aGVyZSBzaW5jZSB0aGUgdXNlciBzcGFjZQ0KPiBhcHBsaWNh
dGlvbiBnZXRzIGl0cyBvd24gZGV2aWNlIGFuZCBzbyBpdHMgb3duIE1BQy9JUCBhbmQgYWxsIG9m
IHRoZSBSRE1BDQo+IHRyYW5zZmVycyBhcmUgVURQLCBzbyB0aGUgYXBwbGljYXRpb24ncyBuYW1l
c3BhY2Ugc2hvdWxkIGdldCBpbmhlcml0ZWQgYnkgYWxsDQo+IHRoZSByZXN0LCBidXQgQ2lzY28g
d291bGQgbmVlZCB0byBjb25maXJtIHRoYXQsIGhlbmNlIHdoeSBJIHNheSA5MCUgb2YgdGhlIHdh
eQ0KPiB0aGVyZSwgaXQgbmVlZHMgY29uZmlybWVkKS4NCg0KVGhpcyBpcyBjb3JyZWN0LiANCg0K
VGhhbmtzDQovQ2hyaXMNCg0K
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
