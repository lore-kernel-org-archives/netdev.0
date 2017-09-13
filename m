From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] nfp: wait more carefully for card init
Date: Wed, 13 Sep 2017 09:39:02 -0700 (PDT)
Message-ID: <20170913.093902.570914704132982694.davem@davemloft.net>
References: <20170913155131.18090-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751117AbdIMQjD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 12:39:03 -0400
In-Reply-To: <20170913155131.18090-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmFrdWIgS2ljaW5za2kgPGpha3ViLmtpY2luc2tpQG5ldHJvbm9tZS5jb20+DQpEYXRl
OiBXZWQsIDEzIFNlcCAyMDE3IDA4OjUxOjI4IC0wNzAwDQoNCj4gVGhlIGZpcnN0IHBhdGNoIGlz
IGEgc21hbGwgZml4IGZvciBmbG93ZXIgb2ZmbG9hZCwgd2UgbmVlZCBhIHdoaXRlbGlzdA0KPiBv
ZiBzdXBwb3J0ZWQgbWF0Y2hlcywgb3RoZXJ3aXNlIHRoZSB1bnN1cHBvcnRlZCBvbmVzIHdpbGwg
YmUgaWdub3JlZC4NCj4gDQo+IFRoZSBzZWNvbmQgYW5kIHRoZSB0aGlyZCBwYXRjaCBhcmUgYWRk
aW5nIHdhaXQvcG9sbGluZyB0byB0aGUgcHJvYmUgcGF0aC4NCj4gV2UgaGFkIHJlcG9ydHMgb2Yg
ZHJpdmVyIGZhaWxpbmcgcHJvYmUgYmVjYXVzZSBpdCBjb3VsZG4ndCBmaW5kIHRoZSANCj4gY29u
dHJvbCBwcm9jZXNzIChOU1ApIG9uIHRoZSBjYXJkLiAgVHVybnMgb3V0IHRoZSBOU1Agd2lsbCBv
bmx5IGFubm91bmNlDQo+IGl0cyBleGlzdGVuY2UgYWZ0ZXIgaXQncyBmdWxseSBpbml0aWFsaXpl
ZC4gIFVudGlsIG5vdyB3ZSBhc3N1bWVkIGl0IA0KPiB3aWxsIGJlIHJlYWNoYWJsZSwganVzdCBu
b3QgcHJvY2Vzc2luZyBjb21tYW5kcyAoaGVuY2Ugd2Ugd2FpdCBmb3INCj4gYSBOT09QIGNvbW1h
bmQgdG8gZXhlY3V0ZSBzdWNjZXNzZnVsbHkpLg0KDQpQbGVhc2UgYnVpbGQgdGVzdCB5b3VyIGNo
YW5nZXMgYW5kIGxvb2sgYXQgd2hhdCB0aGUgY29tcGlsZXIgc2F5czoNCg0KZHJpdmVycy9uZXQv
ZXRoZXJuZXQvbmV0cm9ub21lL25mcC9uZnBfbWFpbi5jOiBJbiBmdW5jdGlvbiChbmZwX2Z3X3Vu
bG9hZKI6DQpkcml2ZXJzL25ldC9ldGhlcm5ldC9uZXRyb25vbWUvbmZwL25mcF9tYWluLmM6Mzk1
OjEwOiB3YXJuaW5nOiChcmV0dXJuoiB3aXRoIGEgdmFsdWUsIGluIGZ1bmN0aW9uIHJldHVybmlu
ZyB2b2lkDQogICByZXR1cm4gZXJyOw0KICAgICAgICAgIF5+fg0KZHJpdmVycy9uZXQvZXRoZXJu
ZXQvbmV0cm9ub21lL25mcC9uZnBfbWFpbi5jOjM4ODoxMzogbm90ZTogZGVjbGFyZWQgaGVyZQ0K
IHN0YXRpYyB2b2lkIG5mcF9md191bmxvYWQoc3RydWN0IG5mcF9wZiAqcGYpDQogICAgICAgICAg
ICAgXn5+fn5+fn5+fn5+fg0K
