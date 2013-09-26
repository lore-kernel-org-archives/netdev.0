From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] net: qmi_wwan: fix checkpatch warnings
Date: Thu, 26 Sep 2013 12:29:06 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B735F@saturn3.aculab.com>
References: <1380100886-16531-1-git-send-email-fabio.porcedda@gmail.com><1380100886-16531-2-git-send-email-fabio.porcedda@gmail.com><877ge5own8.fsf@nemi.mork.no><CAHkwnC-05BdptYjw0H+k=tc5fXq1Tc5pJyDQLGEvUZA5fy2NHQ@mail.gmail.com> <87y56jn9ub.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Dan Williams" <dcbw@redhat.com>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	"Fabio Porcedda" <fabio.porcedda@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45819 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756554Ab3IZLf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 07:35:28 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28399-04 for <netdev@vger.kernel.org>;
 Thu, 26 Sep 2013 12:35:25 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <87y56jn9ub.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBBbnl0aGluZyB0aGF0IGJyZWFrcyBhIHByZXZpb3VzbHkgdW5icm9rZW4gYXJndW1lbnQgbGlz
dCB3aWxsIHJlZHVjZSB0aGUNCj4gcmVhZGFiaWxpdHkgaW4gbXkgb3Bpbmlvbi4gIFRoZSBsaW5l
cyBjYW4gb2YgY291cnNlIG5vdCBiZSB1bmxpbWl0ZWQsDQo+IGJ1dCB0aGVyZSBpcyBubyBuZWVk
IHRvIHNldCB0aGUgbGltaXQgYXMgbG93IGFzIDgwIGNvbHVtbnMuICBGZWVkYmFjaw0KPiBJJ3Zl
IGdvdCBmcm9tIGRldmVsb3BlcnMgdXNpbmcgZS5nLiA4MCBjb2x1bW4gYnJhaWxsZSBkZXZpY2Vz
IGlzIHRoYXQNCj4gbG9uZ2VyIGxpbmVzIGlzbid0IHJlYWxseSBhIHByb2JsZW0gZm9yIHRoZW0g
ZWl0aGVyLg0KDQpUaGUgbWFpbiByZWFzb24gZm9yIGxpbWl0aW5nIHRoZSBsaW5lIGxlbmd0aCBp
cyBzbyB0aGF0IHRoaW5ncyBsb29rDQonc2Vuc2libGUnIHdoZW4geW91IGhhdmUgYSBsb3Qgb2Yg
c2NyZWVuIHdpbmRvd3MgZGlzcGxheWluZyBkaWZmZXJlbnQNCmZpbGVzLiBZb3UgZG9uJ3Qgd2Fu
dCB3cmFwcGVkIGNvZGUsIGFuZCB5b3UgZGVmaW5pdGVseSBkb24ndCB3YW50DQp0aGUgUkhTIG9m
IGxvbmcgbGluZXMgaGlkZGVuLg0KV2l0aCBhIDE2MDB4MTIwMCBtb25pdG9yIEknbGwgZGlzcGxh
eSBzaXggODB4NDAgd2luZG93cyAoYW5kIHByb2JhYmx5DQpoYXZlIHNvbWUgbW9yZSBwYXJ0aWFs
bHkgdmlzaWJsZSBvbmVzKS4NCg0KUGVyc29uYWxseSBJIGluZGVudCBjb250aW51YXRpb24gbGlu
ZXMgYnkgNCBjaGFycyBpZiB1c2luZyA4IGNoYXINCidub3JtYWwnIGluZGVudGF0aW9uIGFuZCA4
IGNoYXJzIGlmIHVzaW5nIDQuIFRoaXMgZ2l2ZXMgYSBsb3QgbW9yZQ0Kcm9vbSBvbiB0aGUgY29u
dGludWF0aW9uIGxpbmVzIHRoYW4gdGhlIExpbnV4ICdsaW5lIHVwIHdpdGggdGhlDQpwcmV2aW91
cyBsaW5lJy4NCg0KPiBUaGlzIGlzIHRoZSBvbmx5IG9uZSBvZiB5b3VyIGNvZGUgY2hhbmdlcyB3
aGljaCBJIGNhbiBiZSBjb252aW5jZWQgdG8NCj4gYWdyZWVpbmcgbWF5IGltcHJvdmUgcmVhZGFi
aWxpdHk6DQo+IA0KPiAtICAgICBpZiAoKG9uICYmIHx8ICghb24gJiYgYXRvbWljX2RlY19hbmRf
dGVzdCgmaW5mby0+cG1jb3VudCkpKSB7DQo+ICsgICAgIGlmICgob24gJiYgYXRvbWljX2FkZF9y
ZXR1cm4oMSwgJmluZm8tPnBtY291bnQpID09IDEpIHx8DQo+ICsgICAgICAgICAoIW9uICYmIGF0
b21pY19kZWNfYW5kX3Rlc3QoJmluZm8tPnBtY291bnQpKSkgew0KDQpUaGF0IGNhbiBiZSB3cml0
dGVuIHN1Y2NpbmN0bHkgYXM6DQoJaWYgKG9uID8gYXRvbWljX2FkZF9yZXR1cm4oMSwgJmluZm8t
PnBtY291bnQpID09IDEpDQoJICAgICAgIDogYXRvbWljX2RlY19hbmRfdGVzdCgmaW5mby0+cG1j
b3VudCkpIHsNCmFsdGhvdWdoIHRoYXQgY29uc3RydWN0IGlzIHNvbWV3aGF0IGZyb3duZWQgdXBv
biENCg0KCURhdmlkDQoNCg==
