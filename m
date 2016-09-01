From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: Don't expose skbs to in-kernel users
Date: Thu, 01 Sep 2016 16:39:42 -0700 (PDT)
Message-ID: <20160901.163942.2272956240456598007.davem@davemloft.net>
References: <147257235268.6716.12062621584578937716.stgit@warthog.procyon.org.uk>
        <147257235952.6716.3613899854387213654.stgit@warthog.procyon.org.uk>
        <20160901.163832.1923741041602397930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901.163832.1923741041602397930.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVGh1LCAwMSBT
ZXAgMjAxNiAxNjozODozMiAtMDcwMCAoUERUKQ0KDQo+IEZyb206IERhdmlkIEhvd2VsbHMgPGRo
b3dlbGxzQHJlZGhhdC5jb20+DQo+IERhdGU6IFR1ZSwgMzAgQXVnIDIwMTYgMTY6NTI6MzkgKzAx
MDANCj4gDQo+PiBEb24ndCBleHBvc2Ugc2ticyB0byBpbi1rZXJuZWwgdXNlcnMsIHN1Y2ggYXMg
dGhlIEFGUyBmaWxlc3lzdGVtLCBidXQNCj4+IGluc3RlYWQgcHJvdmlkZSBhIG5vdGlmaWNhdGlv
biBob29rIHRoZSBpbmRpY2F0ZXMgdGhhdCBhIGNhbGwgbmVlZHMNCj4+IGF0dGVudGlvbiBhbmQg
YW5vdGhlciB0aGF0IGluZGljYXRlcyB0aGF0IHRoZXJlJ3MgYSBuZXcgY2FsbCB0byBiZQ0KPj4g
Y29sbGVjdGVkLg0KPiAgLi4uDQo+PiBTaWduZWQtb2ZmLWJ5OiBEYXZpZCBIb3dlbGxzIDxkaG93
ZWxsc0ByZWRoYXQuY29tPg0KPiANCj4gQXBwbGllZC4NCg0KQWN0dWFsbHksIHJldmVydGVkLCB0
aGlzIGFkZHMgYSBuZXcgd2FybmluZyB0byB0aGUgYnVpbGQ6DQoNCm5ldC9yeHJwYy9yZWN2bXNn
LmM6IEluIGZ1bmN0aW9uIKFyeHJwY19rZXJuZWxfcmVjdl9kYXRhojoNCm5ldC9yeHJwYy9yZWN2
bXNnLmM6NTMxOjE6IHdhcm5pbmc6IGxhYmVsIKFuZWVkX21vcmVfZGF0YaIgZGVmaW5lZCBidXQg
bm90IHVzZWQgWy1XdW51c2VkLWxhYmVsXQ0KIG5lZWRfbW9yZV9kYXRhOg0KIF4NCm5ldC9yeHJw
Yy9yZWN2bXNnLmM6NDc1Ojc6IHdhcm5pbmc6IHVudXNlZCB2YXJpYWJsZSChbm9fbW9yZaIgWy1X
dW51c2VkLXZhcmlhYmxlXQ0KICBib29sIG5vX21vcmU7DQogICAgICAgXg0K
