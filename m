From: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>
Subject: Re: [jkirsher/net-queue PATCH] i40e: Add programming descriptors to
 cleaned_count
Date: Sun, 22 Oct 2017 18:01:47 +0000
Message-ID: <1508695307.4970.32.camel@cohaesio.com>
References: <20171022011222.12997.53593.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bender.cohaesio.com ([212.97.128.130]:59261 "EHLO
        mail.cohaesio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932100AbdJVSBt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 14:01:49 -0400
In-Reply-To: <20171022011222.12997.53593.stgit@localhost.localdomain>
Content-Language: en-US
Content-ID: <021FA87C7F31F448B331135672ADC23A@surftown.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gbMO4ciwgMjAxNy0xMC0yMSBhdCAxODoxMiAtMDcwMCwgQWxleGFuZGVyIER1eWNrIHdyb3Rl
Og0KPiBGcm9tOiBBbGV4YW5kZXIgRHV5Y2sgPGFsZXhhbmRlci5oLmR1eWNrQGludGVsLmNvbT4N
Cj4gDQo+IFRoaXMgcGF0Y2ggdXBkYXRlcyB0aGUgaTQwZSBkcml2ZXIgdG8gaW5jbHVkZSBwcm9n
cmFtbWluZyBkZXNjcmlwdG9ycw0KPiBpbg0KPiB0aGUgY2xlYW5lZF9jb3VudC4gV2l0aG91dCB0
aGlzIGNoYW5nZSBpdCBiZWNvbWVzIHBvc3NpYmxlIGZvciB1cyB0bw0KPiBsZWFrDQo+IG1lbW9y
eSBhcyB3ZSBkb24ndCB0cmlnZ2VyIGEgbGFyZ2UgZW5vdWdoIGFsbG9jYXRpb24gd2hlbiB0aGUg
dGltZQ0KPiBjb21lcyB0bw0KPiBhbGxvY2F0ZSBuZXcgYnVmZmVycyBhbmQgd2UgZW5kIHVwIG92
ZXJ3cml0aW5nIGEgbnVtYmVyIG9mIHJ4X2J1ZmZlcnMNCj4gZXF1YWwNCj4gdG8gdGhlIG51bWJl
ciBvZiBwcm9ncmFtbWluZyBkZXNjcmlwdG9ycyB3ZSBlbmNvdW50ZXJlZC4NCj4gDQo+IEZpeGVz
OiAwZTYyNmZmN2NjYmYgKCJpNDBlOiBGaXggc3VwcG9ydCBmb3IgZmxvdyBkaXJlY3RvciBwcm9n
cmFtbWluZw0KPiBzdGF0dXMiKQ0KPiBTaWduZWQtb2ZmLWJ5OiBBbGV4YW5kZXIgRHV5Y2sgPGFs
ZXhhbmRlci5oLmR1eWNrQGludGVsLmNvbT4NCg0KVGhpcyBwYXRjaCBzb2x2ZXMgdGhlIHJlbWFp
bmluZyBtZW1vcnkgbGVhayB3ZSd2ZSBzZWVuLCBzbw0KDQpUZXN0ZWQtYnk6IEFuZGVycyBLLiBQ
ZWRlcnNlbiA8YWtwQGNvaGFlc2lvLmNvbT4NCg0KUmVnYXJkcywNCkFuZGVycw==
