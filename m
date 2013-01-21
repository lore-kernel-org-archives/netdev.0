From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: [PATCH net 2/3] net: cdc_mbim: send ZLP after max sized NTBs
Date: Mon, 21 Jan 2013 17:31:37 +0100
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D57@EXDCVYMBSTM006.EQ1STM.local>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
 <1358783440-11459-3-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358783440-11459-3-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCasO4cm4gTW9yayBbbWFpbHRv
OmJqb3JuQG1vcmsubm9dDQo+IA0KPiBXZSBub3JtYWxseSBhdm9pZCBzZW5kaW5nIFpMUHMgYnkg
cGFkZGluZyBOVEJzIHdpdGggYSB6ZXJvIGJ5dGUgaWYgdGhlDQo+IE5UQiBpcyBzaG9ydGVyIHRo
YW4gZHdOdGJPdXRNYXhTaXplLCByZXN1bHRpbmcgaW4gYSBzaG9ydCBVU0IgcGFja2V0DQo+IGlu
c3RlYWQgb2YgYSBaTFAuICBCdXQgaW4gdGhlIGNhc2Ugd2hlcmUgdGhlIE5UQiBsZW5ndGggaXMg
ZXhhY3RseQ0KPiBkd050Yk91dE1heFNpemUgYW5kIHRoaXMgaXMgYW4gZXhhY3QgbXVsdGlwbHVt
IG9mIHdNYXhQYWNrZXRTaXplLCB0aGVuDQo+IHdlIG11c3Qgc2VuZCBhIFpMUC4NCj4gDQo+IFRo
aXMgZml4ZXMgYW4gaXNzdWUgc2VlbiBvbiBhIFNpZXJyYSBXaXJlbGVzcyBNQzc3MTAgZGV2aWNl
IHdoZXJlIHRoZQ0KPiB0cmFuc21pc3Npb24gd291bGQgZmFpbCB3aGVuZXZlciB3ZSBlbmRlZCB1
cCBwYWRkaW5nIHRoZSBOVEJzIHRvIG1heA0KPiBzaXplLg0KDQpJZiB5b3UgYWRkIFpMUCBmb3Ig
TlRCcyBvZiBkd050Yk91dE1heFNpemUsIHlvdSBhcmUgaGVhdmlseSBhZmZlY3RpbmcgQ1BVDQps
b2FkLCBpbmNyZWFzaW5nIGludGVycnVwdCBsb2FkIGJ5IGZhY3RvciBvZiAyIGluIGhpZ2ggbG9h
ZCB0cmFmZmljDQpzY2VuYXJpbyBhbmQgcG9zc2libHkgZGVjcmVhc2luZyB0aHJvdWdocHV0IGZv
ciBhbGwgb3RoZXIgZGV2aWNlcw0Kd2hpY2ggYmVoYXZlcyBjb3JyZWN0bHkuIA0KDQpXaHkgc2hv
dWxkIG90aGVycyBwYXkgZm9yIFNpZXJyYSBXaXJlbGVzcyBmYXVsdD8NCg0KQXQgbGVhc3QsIGRv
IGNoZWNrIFZJRC9QSUQgaW4gdXNibmV0IGFuZCBzZW5kIFpMUCBvbmx5IGZvciBtYWxmdW5jdGlv
bmluZyANCmRldmljZXMuDQoNClJlZ2FyZHMsDQpBbGV4ZXkNCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
