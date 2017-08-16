From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/10] BPF: sockmap and sk redirect support
Date: Wed, 16 Aug 2017 11:35:01 -0700 (PDT)
Message-ID: <20170816.113501.1961184995639656444.davem@davemloft.net>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
        <20170816.112819.1162151697604053267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: daniel@iogearbox.net, ast@fb.com, tgraf@suug.ch,
        netdev@vger.kernel.org, tom@herbertland.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752437AbdHPSfC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:35:02 -0400
In-Reply-To: <20170816.112819.1162151697604053267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogV2VkLCAxNiBB
dWcgMjAxNyAxMToyODoxOSAtMDcwMCAoUERUKQ0KDQo+IEZyb206IEpvaG4gRmFzdGFiZW5kIDxq
b2huLmZhc3RhYmVuZEBnbWFpbC5jb20+DQo+IERhdGU6IFR1ZSwgMTUgQXVnIDIwMTcgMjI6MzA6
MTUgLTA3MDANCj4gDQo+PiBUaGlzIHNlcmllcyBpbXBsZW1lbnRzIGEgc29ja21hcCBhbmQgc29j
a2V0IHJlZGlyZWN0IGhlbHBlciBmb3IgQlBGDQo+PiB1c2luZyBhIG1vZGVsIHNpbWlsYXIgdG8g
WERQIG5ldGRldiByZWRpcmVjdC4NCj4gDQo+IFNlcmllcyBhcHBsaWVkLCB0aGFua3MgSm9obi4N
Cj4gDQoNCldlIGdldCBhIGxlZ2l0IHdhcm5pbmcgZnJvbSBnY2MgZHVlIHRvIHRoZXNlIGNoYW5n
ZXM6DQoNCmtlcm5lbC9icGYvc29ja21hcC5jOiBJbiBmdW5jdGlvbiChc21hcF9zdGF0ZV9jaGFu
Z2WiOg0Ka2VybmVsL2JwZi9zb2NrbWFwLmM6MTU2OjIxOiB3YXJuaW5nOiChcHNvY2uiIG1heSBi
ZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5jdGlvbiBbLVdtYXliZS11bmluaXRpYWxp
emVkXQ0KICBzdHJ1Y3Qgc21hcF9wc29jayAqcHNvY2s7DQoNCkl0J3MgdGhlIGRlZmF1bHQgc3dp
dGNoIGNhc2UgaW4gdGhpcyBmdW5jdGlvbiwgcHNvY2sgaXMgbm90IGluaXRpYWxpemVkDQpmb3Ig
c3VyZSBhdCB0aGlzIHBvaW50Lg0K
