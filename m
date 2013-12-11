From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: mv643xx_eth: properly start/stop phy device
Date: Tue, 10 Dec 2013 21:56:54 -0500 (EST)
Message-ID: <20131210.215654.1165181423931409066.davem@davemloft.net>
References: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1386513631-11284-2-git-send-email-sebastian.hesselbarth@gmail.com>
	<20131210.215253.2121948728095674632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: f.fainelli@gmail.com, mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131210.215253.2121948728095674632.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAxMCBE
ZWMgMjAxMyAyMTo1Mjo1MyAtMDUwMCAoRVNUKQ0KDQo+IA0KPiBUaGlzIHNlcmllcyBsb29rcyBn
b29kLCBhcHBsaWVkIHRvIG5ldC1uZXh0LCB0aGFua3MuDQoNCkFjdHVhbGx5LCBJIGhhZCB0byBy
ZXZlcnQuDQoNCllvdSBjYW5ub3QgdXNlIGxhdGVfaW5pdGNhbGxfc3luYygpIGZyb20gY29kZSB0
aGF0IGlzIHBvdGVudGlhbGx5DQpidWlsdCBtb2R1bGFyLCB0aGlzIGNhdXNlZCBteSBidWlsZCB0
byBmYWlsIGF0IHRoZSBtZGlvX2J1cyBjb2RlLg0KDQpkcml2ZXJzL25ldC9waHkvbWRpb19idXMu
YzozNDQ6MTogd2FybmluZzogZGF0YSBkZWZpbml0aW9uIGhhcyBubyB0eXBlIG9yIHN0b3JhZ2Ug
Y2xhc3MgW2VuYWJsZWQgYnkgZGVmYXVsdF0NCmRyaXZlcnMvbmV0L3BoeS9tZGlvX2J1cy5jOjM0
NDoxOiBlcnJvcjogdHlwZSBkZWZhdWx0cyB0byChaW50oiBpbiBkZWNsYXJhdGlvbiBvZiChbGF0
ZV9pbml0Y2FsbF9zeW5joiBbLVdlcnJvcj1pbXBsaWNpdC1pbnRdDQpkcml2ZXJzL25ldC9waHkv
bWRpb19idXMuYzozNDQ6MTogd2FybmluZzogcGFyYW1ldGVyIG5hbWVzICh3aXRob3V0IHR5cGVz
KSBpbiBmdW5jdGlvbiBkZWNsYXJhdGlvbiBbZW5hYmxlZCBieSBkZWZhdWx0XQ0KZHJpdmVycy9u
ZXQvcGh5L21kaW9fYnVzLmM6MzM5OjEyOiB3YXJuaW5nOiChbWRpb19idXNfY2xhc3Nfc3VzcGVu
ZF91bnVzZWSiIGRlZmluZWQgYnV0IG5vdCB1c2VkIFstV3VudXNlZC1mdW5jdGlvbl0NCg==
