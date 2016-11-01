From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: XDP question - how much can BPF change in xdp_buff?
Date: Tue, 1 Nov 2016 07:06:02 +0000
Message-ID: <BL2PR07MB230697FE88472B88AC400B808DA10@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <BY2PR07MB23090DE460B0AE6AA23CD7368DAE0@BY2PR07MB2309.namprd07.prod.outlook.com>
 <CALx6S37bfMpMhWTSL-WzumGfqywi0oJPnLqj_yEUs61AtyLZKA@mail.gmail.com>
 <BL2PR07MB2306ED437FAFA98CBA49E07F8DA10@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0065.outbound.protection.outlook.com ([104.47.34.65]:24192
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752671AbcKAHGE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 03:06:04 -0400
In-Reply-To: <BL2PR07MB2306ED437FAFA98CBA49E07F8DA10@BL2PR07MB2306.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBCVFcsIGFyZSB3ZSBjb25zaWRlcmluZyBzb21lIG9mZmxvYWQgd2hlcmUgdGhlIGVCUEYgd291
bGQgcmV0dXJuICBhIHNldCBvZg0KPiBjaGFuZ2VzIFtiYXNlZCBvbiBzb21lIHByZS1zZXQgY2Fw
YWJpbGl0aWVzIHNldCBieSBkcml2ZXJdIGRvbmUgb24gYnVmZmVyIGFuZCBsZXQNCj4gdGhlIEhX
IG9mZmxvYWQgdGhvc2U/DQo+IA0KPiBJIHVuZGVyc3RhbmQgZW5kIGdvYWwgaXMgZUJQRiBody1v
ZmZsb2FkaW5nLCBidXQgc2VlbXMgbGlrZSB0aGVyZSBhcmUgYSBsb3Qgb2YNCj4gZXhpc3Rpbmcg
b2ZmbG9hZCBmYWNpbGl0aWVzIHRoYXQgbWlnaHQgYmUgbGV2ZXJhZ2VkLg0KDQpPbiBzZWNvbmQg
dGhvdWdodCwgZ2l2ZW4gdGhhdCB0aGUgcHJvZ3JhbSBpcyBsaWtlbHkgdG8gY2hhbmdlIG9ubHkg
YQ0Kc21hbGwgc2V0IG9mIGZpZWxkcyBbYXMgb3Bwb3NlZCB0byBidWlsZGluZyB3aG9sZSBuZXcg
YnVmZmVyc10sDQpwcm9iYWJseSBmaXhpbmcgdGhlIGNzdW0gaXNuJ3QgZ29pbmcgdG8gYmUgbXVj
aCBjb3N0bGllciBbaWYgYXQgYWxsXSB0aGVuIHRoZSBsb2dpYw0KdGhhdCB3b3VsZCBiZSByZXF1
aXJlZCB0byBkZXRlcm1pbmUgd2hldGhlciB0aGUgZGV2aWNlIHdvdWxkIGJlIGFibGUgdG8gb2Zm
bG9hZA0KaXQuDQo=
