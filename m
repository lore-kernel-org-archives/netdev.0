From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/2] arp: flush arp cache on IFF_NOARP change
Date: Thu, 23 May 2013 11:23:28 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7249@saturn3.aculab.com>
References: <1369303109-12003-1-git-send-email-timo.teras@iki.fi> <1369303109-12003-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
To: =?utf-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57743 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757918Ab3EWKYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 06:24:10 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26690-05 for <netdev@vger.kernel.org>;
 Thu, 23 May 2013 11:24:06 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1369303109-12003-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJRkZfTk9BUlAgYWZmZWN0cyB3aGF0IGtpbmQgb2YgbmVpZ2hib3IgZW50cmllcyBhcmUgY3Jl
YXRlZA0KPiAobnVkIE5PQVJQIG9yIG51ZCBJTkNPTVBMRVRFKS4gSWYgdGhlIGZsYWcgY2hhbmdl
cywgZmx1c2ggdGhlIGFycA0KPiBjYWNoZSB0byByZWZyZXNoIGFsbCBlbnRyaWVzLg0KDQpNaWdo
dCBzb21lb25lIHdhbnQgdG8gdXNlIHRoaXMgdG8gc3RvcCBmdXJ0aGVyIGFycCB0YWJsZQ0KZW50
cmllcyBiZWluZyBjcmVhdGVkPw0KSW4gd2hpY2ggY2FzZSB5b3UgZG9uJ3Qgd2FudCBhbnl0aGlu
ZyBmbHVzaGVkLg0KDQoJRGF2aWQNCg0K
