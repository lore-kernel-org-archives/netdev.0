From: "Seymour, Shane M" <shane.seymour@hpe.com>
Subject: RE: [PATCH net-next] tcp: increase size at which
 tcp_bound_to_half_wnd bounds to > TCP_MSS_DEFAULT
Date: Tue, 28 Jun 2016 22:51:08 +0000
Message-ID: <CS1PR84MB0295F44AA41F27857EC2E9B6FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
References: <CS1PR84MB0295E420892A535E40FE338EFD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
	 <1467115090.6850.202.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CS1PR84MB02950F38FF1801E89612B9E4FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
 <1467153342.6850.205.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0144.outbound.protection.outlook.com ([207.46.100.144]:55368
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752466AbcF1WvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 18:51:19 -0400
In-Reply-To: <1467153342.6850.205.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBZ
b3VyIGRpZmYgaXMgcmV2ZXJzZWQuIA0KDQpTb3JyeSBteSBhcG9sb2dpZXMsIEknbGwgc2VuZCBh
IFYyLiANCg0K
