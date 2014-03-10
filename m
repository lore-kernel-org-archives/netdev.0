From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH v3 net-next 1/2] ethtool: Support for configurable RSS
 hash key
Date: Mon, 10 Mar 2014 11:13:23 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C88CD93@CMEXMB1.ad.emulex.com>
References: <1393589141-10597-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <0e1d7b54-dcbd-446d-b1c9-644086da138f@CMEXHTCAS2.ad.emulex.com>
	 <1394063979.2861.25.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C889D94@CMEXMB1.ad.emulex.com>
 <1394407382.15968.84.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:7150 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961AbaCJLNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 07:13:25 -0400
In-Reply-To: <1394407382.15968.84.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ID4gV2h5IGlzIDB4REVBREJFRUYgc3BlY2lhbD8NCj4gPiBTaW5jZSAwIGlzIHVzZWQgYXMg
YSBoaW50IHRvIHJlc2V0IHRvIGRlZmF1bHQsIHdlIHNob3VsZCBoYXZlIGEgd2F5IHRvDQo+ID4g
aGludCB0aGF0IGluZGlyZWN0aW9uIHRhYmxlIGNvbmZpZ3VyYXRpb24gaXMgbm90IHJlcXVlc3Rl
ZCBpbiB0aGlzDQo+ID4gY29udGV4dC4NCj4gDQo+IFRoYXQncyBub3QgbmVjZXNzYXJ5LCBhcyB5
b3UgY2FuIHJlYWQgYW5kIHRoZW4gd3JpdGUgYmFjayB0aGUgc2FtZSB2YWx1ZXMuDQo+IA0KPiBC
ZW4uDQoNCk1heSBiZSB0aGlzIGlzIGV4dHJlbWVseSBoeXBvdGhldGljYWwgYnV0IHdoYXQgaWYg
YSBkcml2ZXIgZG9lc24ndCB3YW50IHRvIHN1cHBvcnQgaW5kaXJlY3Rpb24gY29uZmlndXJhdGlv
biBhbmQgb25seSB3YW50cyB0byBzdXBwb3J0IGhhc2gga2V5IGNvbmZpZ3VyYXRpb24uDQpJbiBz
dWNoIGEgY2FzZSwgdGhlIGtlcm5lbCBzaG91bGQga25vdyB0aGF0IGFyZSBubyBlbnRyaWVzIG9m
IGluZGlyZWN0aW9uIGluIHJzc19jb25maWcuIEFsc28gSSB0aGluayBpdCdzIGJldHRlciB0byBr
ZWVwIGhhc2gga2V5IGFuZCBpbmRpcmVjdGlvbiBjb25maWd1cmF0aW9ucyBpbmRlcGVuZGVudCBv
ZiBlYWNoIG90aGVyLg0K
