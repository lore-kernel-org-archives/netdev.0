From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: remove redundant checking for sock timer state
Date: Fri, 1 Feb 2013 09:26:58 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B712D@saturn3.aculab.com>
References: <1359697980-28613-1-git-send-email-ying.xue@windriver.com>	 <20130201.010946.584437309593473452.davem@davemloft.net> <1359700003.30177.32.camel@edumazet-glaptop> <510B6B4B.8080205@gmail.com> <1359703264.30177.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David Miller" <davem@davemloft.net>, <ying.xue@windriver.com>,
	<netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Xue Ying" <ying.xue0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59960 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752905Ab3BAJ1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 04:27:30 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10208-10 for <netdev@vger.kernel.org>;
 Fri,  1 Feb 2013 09:27:27 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1359703264.30177.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJIHNhaWQgdGhhdCB0aGUgb2xkIGNvbnN0cnVjdCA6DQo+IA0KPiBpZiAodGltZXJfcGVuZGlu
ZyhYKSkNCj4gICAgIGRlbF90aW1lcihYKTsNCj4gDQo+IGNvdWxkIGJlIGNoYW5nZWQgdG8NCj4g
DQo+IGRlbF90aW1lcihYKTsNCg0KSWYgdGltZXJfcGVuZGluZygpIGlzIGFuIGlubGluZSBmdW5j
dGlvbiB0aGVuIHRoZSBhZGRpdGlvbmFsIGNoZWNrDQptaWdodCBiZSBiZW5lZmljaWFsIGluIHZl
cnkgaG90IHBhdGhzLg0KDQoJRGF2aWQNCg0K
