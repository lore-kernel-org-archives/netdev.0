From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2] net: adjust skb_gso_segment() for calling in rx path
Date: Wed, 6 Feb 2013 09:48:54 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7139@saturn3.aculab.com>
References: <1360118198-25440-1-git-send-email-amwang@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7138@saturn3.aculab.com> <1360143032.23727.8.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, "Jesse Gross" <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Cong Wang" <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57618 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751866Ab3BFJta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 04:49:30 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19172-10 for <netdev@vger.kernel.org>;
 Wed,  6 Feb 2013 09:49:26 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1360143032.23727.8.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPbiBXZWQsIDIwMTMtMDItMDYgYXQgMDk6MjMgKzAwMDAsIERhdmlkIExhaWdodCB3cm90ZToN
Cj4gPiA+ICsvKiBvcGVudnN3aXRjaCBjYWxscyB0aGlzIG9uIHJ4IHBhdGgsIHNvIHdlIG5lZWQg
YSBkaWZmZXJlbnQgY2hlY2suDQo+ID4gPiArICovDQo+ID4gPiArc3RhdGljIGlubGluZSBib29s
IHNrYl9uZWVkc19jaGVjayhzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBib29sIHR4X3BhdGgpDQo+ID4g
PiArew0KPiA+ID4gKwlpZiAodHhfcGF0aCkNCj4gPiA+ICsJCXJldHVybiBza2ItPmlwX3N1bW1l
ZCAhPSBDSEVDS1NVTV9QQVJUSUFMOw0KPiA+ID4gKwllbHNlDQo+ID4gPiArCQlyZXR1cm4gc2ti
LT5pcF9zdW1tZWQgPT0gQ0hFQ0tTVU1fTk9ORTsNCj4gPiA+ICt9DQo+ID4gPiArDQo+ID4NCj4g
PiBUaGF0IGNvZGUgd2FudHMgYSBsb3Qgb2YgdW5saWtlbHkoKSBhZGRlZC4NCj4gPg0KPiA+IEl0
IHNlZW1zIHdyb25nIHRvIGJlIGFkZGluZyBjb2RlIGEgdmVyeSBjb21tb24gcGF0aCBmb3Igb25l
DQo+ID4gb2JzY3VyZSBjYWxsZXIuDQo+IA0KPiBJdHMgY2FsbGVyIGRvZXM6DQo+IA0KPiArICAg
ICAgIGlmICh1bmxpa2VseShza2JfbmVlZHNfY2hlY2soc2tiLCB0eF9wYXRoKSkpIHsNCg0KSW4g
bXkgZXhwZXJpZW5jZSB0aGF0IGlzbid0IGVub3VnaCB0byBnZXQgYWxsIHRoZSBzdWItdGVzdHMN
Cm9mIGNvbXBsZXggY29uZGl0aW9uYWxzIGNvbXBpbGVkIGluIHRoZSBkZXNpcmVkIHdheS4NCg0K
CURhdmlkDQoNCg==
