From: "Yu Zhiguo" <yuzg@nanjing-fnst.com>
Subject: Re: Netlink send from the interrupt context
Date: Wed, 23 Nov 2005 17:04:13 +0800
Message-ID: <033701c5f00c$e0282bd0$6704a8c0@skqianyi>
References: <7e63f56c0511210034h49917721k74ddb251b9bb1815@mail.gmail.com>
	<00a901c5ee79$389e5040$6704a8c0@skqianyi>
	<7e63f56c0511222328w6368f7bcl7877fe3aa62c2807@mail.gmail.com>
	<02e501c5f002$e5094d00$6704a8c0@skqianyi>
	<7e63f56c0511230004j79c7f080j56e25251387ebe94@mail.gmail.com>
	<031201c5f007$0ce2e1c0$6704a8c0@skqianyi>
	<7e63f56c0511230032x5097569dr3ddac4b05bb6019c@mail.gmail.com>
	<7e63f56c0511230033w68e60863wb8a026df3eea3077@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "Robert Iakobashvili" <coroberti@gmail.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

eWVzLCBpdCB1c2Ugc3BpbmxvY2tzIHJhdGhlciB0aGFuIHNlbWFwaG9yZSwgYW5kIGl0IGNhbiB1
c2UgR0ZQX0FUT01JQyB0byBjbG9uZSB0aGUgbWVzc2FnZSwgDQpzbyBJIHRoaW5rIGl0IHdpbGwg
bm90IGdvIHNsZWVwLg0KDQpyZWdhcmRzLA0KLS0tLS0gT3JpZ2luYWwgTWVzc2FnZSAtLS0tLSAN
Cg0KPiBPbiAxMS8yMy8wNSwgUm9iZXJ0IElha29iYXNodmlsaSA8Y29yb2JlcnRpQGdtYWlsLmNv
bT4gd3JvdGU6DQo+PiBPbiAxMS8yMy8wNSwgWXUgWmhpZ3VvIDx5dXpnQG5hbmppbmctZm5zdC5j
b20+IHdyb3RlOg0KPj4gPiBQbGVhc2UgcmVmZXIgdG8gdGhlIGZ1bmN0aW9uIG5ldGxpbmtfYnJv
YWRjYXN0KCksDQo+PiA+ICAgIGludCBuZXRsaW5rX2Jyb2FkY2FzdChzdHJ1Y3Qgc29jayAqc3Nr
LCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCB1MzIgcGlkLCB1MzIgZ3JvdXAsIGludCBhbGxvY2F0aW9u
KQ0KPj4gPiBJIHRoaW5rIGlmIGFsbG9jYXRpb249R0ZQX0FUT01JQywgaXQgY2FuIGJlIHVzZWQg
aW4gaW50ZXJydXB0IGNvbnRleHQuDQo+PiA+IFdoYXQncyB5b3VyIG9waW5pb24/DQo+IA0KPiBB
bGxvY2F0aW9uIGlzIE9LIGFuZCBpdCB1c2VzIG9ubHkgc3BpbmxvY2tzIGluIGFsbCBmdW5jdGlv
bnMgY2FsbGVkLA0KPiBubyBzZW1hcGhvcmVzLg0KPiANCj4gTXkgY29uY2VybiBhY3R1YWxseSBy
aXNlcyBmcm9tIGhlcmU6DQo+IGh0dHA6Ly93d3cudXNzZy5pdS5lZHUvaHlwZXJtYWlsL2xpbnV4
L2tlcm5lbC8wNDA3LjMvMDQ1NS5odG1sDQo+IA0KPiBTaW5jZXJlbHksDQo+IC0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCj4g
Um9iZXJ0IElha29iYXNodmlsaSAgLSBOQVZJR0FSRSBORUNFU1NFIEVTVA0KPiBjb3JvYmVydGkg
YXQgZ21haWwgZG90IGNvbQ0KPiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0=
