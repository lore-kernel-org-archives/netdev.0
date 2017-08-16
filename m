From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/10] BPF: sockmap and sk redirect support
Date: Wed, 16 Aug 2017 12:13:05 -0700 (PDT)
Message-ID: <20170816.121305.1824274693019781357.davem@davemloft.net>
References: <20170816.112819.1162151697604053267.davem@davemloft.net>
        <20170816.113501.1961184995639656444.davem@davemloft.net>
        <599497BC.6010205@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: daniel@iogearbox.net, ast@fb.com, tgraf@suug.ch,
        netdev@vger.kernel.org, tom@herbertland.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbdHPTNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 15:13:06 -0400
In-Reply-To: <599497BC.6010205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSm9obiBGYXN0YWJlbmQgPGpvaG4uZmFzdGFiZW5kQGdtYWlsLmNvbT4NCkRhdGU6IFdl
ZCwgMTYgQXVnIDIwMTcgMTI6MDY6MzYgLTA3MDANCg0KPiBPbiAwOC8xNi8yMDE3IDExOjM1IEFN
LCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+PiBGcm9tOiBEYXZpZCBNaWxsZXIgPGRhdmVtQGRhdmVt
bG9mdC5uZXQ+DQo+PiBEYXRlOiBXZWQsIDE2IEF1ZyAyMDE3IDExOjI4OjE5IC0wNzAwIChQRFQp
DQo+PiANCj4+PiBGcm9tOiBKb2huIEZhc3RhYmVuZCA8am9obi5mYXN0YWJlbmRAZ21haWwuY29t
Pg0KPj4+IERhdGU6IFR1ZSwgMTUgQXVnIDIwMTcgMjI6MzA6MTUgLTA3MDANCj4+Pg0KPj4+PiBU
aGlzIHNlcmllcyBpbXBsZW1lbnRzIGEgc29ja21hcCBhbmQgc29ja2V0IHJlZGlyZWN0IGhlbHBl
ciBmb3IgQlBGDQo+Pj4+IHVzaW5nIGEgbW9kZWwgc2ltaWxhciB0byBYRFAgbmV0ZGV2IHJlZGly
ZWN0Lg0KPj4+DQo+Pj4gU2VyaWVzIGFwcGxpZWQsIHRoYW5rcyBKb2huLg0KPj4+DQo+PiANCj4+
IFdlIGdldCBhIGxlZ2l0IHdhcm5pbmcgZnJvbSBnY2MgZHVlIHRvIHRoZXNlIGNoYW5nZXM6DQo+
PiANCj4+IGtlcm5lbC9icGYvc29ja21hcC5jOiBJbiBmdW5jdGlvbiChc21hcF9zdGF0ZV9jaGFu
Z2WiOg0KPj4ga2VybmVsL2JwZi9zb2NrbWFwLmM6MTU2OjIxOiB3YXJuaW5nOiChcHNvY2uiIG1h
eSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5jdGlvbiBbLVdtYXliZS11bmluaXRp
YWxpemVkXQ0KPj4gICBzdHJ1Y3Qgc21hcF9wc29jayAqcHNvY2s7DQo+PiANCj4+IEl0J3MgdGhl
IGRlZmF1bHQgc3dpdGNoIGNhc2UgaW4gdGhpcyBmdW5jdGlvbiwgcHNvY2sgaXMgbm90IGluaXRp
YWxpemVkDQo+PiBmb3Igc3VyZSBhdCB0aGlzIHBvaW50Lg0KPj4gDQo+IA0KPiBJIG1pc3NlZCB0
aGlzIHdpdGggb2xkZXIgZ2NjNCBpdCBzZWVtcy4gRml4ZWQgbm93IGFuZCBjb21waWxpbmcgd2l0
aG91dCBlcnJvcnMNCj4gbm93IHdpdGggZ2NjNC81LiBCZWxvdyBpcyB0aGUgZGlmZiBhbmQgYWxs
IHZlcmlmaWVyL3NvY2ttYXAgdGVzdHMgcGFzcy4gV2FudCBhDQo+IHYyIEkgcHJlc3VtZT8NCg0K
SSBhbHJlYWR5IHB1c2hlZCBvdXQgdjEsIHNvIHlvdSdsbCBuZWVkIHRvIHNlbmQgbWUgYSBmaXh1
cCBwYXRjaC4NCg==
