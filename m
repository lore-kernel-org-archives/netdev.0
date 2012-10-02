From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH 3/3] net/mlx4_en: Add HW timestamping (TS) support
Date: Tue, 2 Oct 2012 07:32:17 +0000
Message-ID: <953B660C027164448AE903364AC447D287224734@MTLDAG01.mtl.com>
References: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
	 <1348826603-17439-4-git-send-email-yevgenyp@mellanox.com>
 <1349104125.2577.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:38404 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753113Ab2JBHqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 03:46:08 -0400
In-Reply-To: <1349104125.2577.7.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ICsNCj4gPiArCWlmIChyeF9maWx0ZXIgIT0gSFdUU1RBTVBfRklMVEVSX05PTkUpDQo+ID4g
KwkJZGV2LT5mZWF0dXJlcyAmPSB+TkVUSUZfRl9IV19WTEFOX1JYOw0KPiA+ICsJZWxzZQ0KPiA+
ICsJCWRldi0+ZmVhdHVyZXMgfD0gTkVUSUZfRl9IV19WTEFOX1JYOw0KPiBbLi4uXQ0KPiANCj4g
SWYgeW91IGNoYW5nZSBkZXYtPmZlYXR1cmVzIHlvdSBzaG91bGQgYWxzbyBjYWxsDQo+IG5ldGRl
dl9mZWF0dXJlc19jaGFuZ2UoZGV2KSAoaG9sZGluZyBvbmx5IHRoZSBSVE5MIGxvY2ssIHNvIGFm
dGVyIHlvdQ0KPiB1bmxvY2sgbWRldi0+c3RhdGVfbG9jaykuDQo+IA0KPiBCZW4uDQo+IA0KVGhh
bmtzIEJlbiwNCldpbGwgZml4Lg0KDQpZZXZnZW55DQo=
