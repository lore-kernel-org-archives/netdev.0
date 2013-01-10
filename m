From: Kosta Zertsekel <konszert@marvell.com>
Subject: RE: [PATCH 2/2] Fix phy_attach - forward dev_flags for phy_attach
Date: Thu, 10 Jan 2013 17:57:25 +0200
Message-ID: <BC373419EB4337418B2B595BAEDC155F015896370062@IL-MB01.marvell.com>
References: <1357819234-27752-1-git-send-email-konszert@marvell.com>
 <1357819234-27752-3-git-send-email-konszert@marvell.com>
 <50EED2E4.80008@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zertsekel@gmail.com" <zertsekel@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Eran Ben-Avi <benavi@marvell.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:7329 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab3AJP53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 10:57:29 -0500
In-Reply-To: <50EED2E4.80008@openwrt.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBCeSB0aGUgd2F5LCBtb3N0LCBpZiBub3QgYWxsIG9mIHRoZSBwaHlfY29ubmVjdCgpIHVzZXJz
IGluIGRyaXZlcnMvbmV0L2V0aGVybmV0LyBhbHNvIGRvIG5vdCBlbnN1cmUgdGhleSBwYXNzIHRo
ZSBwaHkgZGV2aWNlIGZsYWdzLCBzbyB5b3UgbWlnaHQgDQoNCndhbnQgdG8gZml4IHRoaXMgZ2xv
YmFsbHkgYW5kIG5vdCBqdXN0IGZvciBNYXJ2ZWxsIGRyaXZlci4NCkluZGVlZCwgcGh5X2Nvbm5l
Y3QoKSBtb3N0bHkganVzdCBwYXNzIHplcm8gaW50ZWFkIG9mIHBoeV9kZXYtPmRldl9mbGFncy4N
CkJ1dCwgSSB0aGluaywgdGhlIGd1eSB0aGF0IGNhbGxzIHBoeV9jb25uZWN0KCkgaW4gaXRzIGRy
aXZlciBzaG91bGQga25vdyB3aGF0IGhlIGRvZXMsIGFuZCwNCnByb2JhYmx5LCB3ZSBzaG91bGQg
cmVseSBvbiBoaW0ga25vd2luZyBoaXMgc3R1ZmYuDQpUaGUgb25seSBldmlkZW5jZSBvZiB0aGUg
YnVnIGlzIHdoZW4gcGh5X2Rldi0+ZGV2X2ZsYWdzIHdhcyBhY3R1YWxseSBjaGFuZ2VkIGJ5IFBI
WSBmaXh1cCBjYWxsYmFjaw0KKHNlZSBkbnMzMjMtc2V0dXAuYyBmb3IgZXhhbXBsZSkgYW5kIHdh
cyAqbm90KiBwcm9wYWdhdGVkIHRvIHBoeV9jb25uZWN0KCkgb3IgcGh5X2F0dGFjaCgpIGFzIGlu
IHB4YTE2OF9ldGguYyBwaHlfaW5pdCgpLg0KVGhlIGNvZGUgY29uZm9ybWluZyB0byB0aGUgZm9y
bWVyIHNob3VsZCBiZSBmaXhlZCBJTUhPLg0KDQpUaGFua3MsDQotLS0gS29zdGFaDQo=
