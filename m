From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 13:40:27 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B725C@saturn3.aculab.com>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com> <20130528.233647.1209227470109213894.davem@davemloft.net> <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com> <20130529194438.GY3333@ritirata.org> <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7259@saturn3.aculab.com> <20130530114556.GC2475@ritirata.org> <AE90C24D6B3A694183C094C60CF0A2F6026B725A@saturn3.aculab.com> <AE90C24D6B3A694183C094C60CF0A2F6026B725B@saturn3.aculab.com> <20130530122459.GE2475@ritirata.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>, <amwang@redhat.com>,
	<netdev@vger.kernel.org>, <horms@verge.net.au>
To: "Antonio Quartulli" <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50605 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753405Ab3E3MlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 08:41:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26146-05 for <netdev@vger.kernel.org>;
 Thu, 30 May 2013 13:41:02 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130530122459.GE2475@ritirata.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IEV4Y2VwdCBJIGNvcGllZCB0aGUgd3JvbmcgZm9ybWF0IGxpbmUgOi0oIEl0IHNob3VsZCBi
ZToNCj4gPiAgCXByaW50ZigiJXggJXggJXggJXggJXggJXggJWx4ICVseCAlbGx4ICVsbHhcbiIs
DQo+ID4gIAkJQUxMX09ORVMoYSksIEFMTF9PTkVTKGIpLCBBTExfT05FUyhjKSwgQUxMX09ORVMo
ZCksDQo+ID4gIAkJQUxMX09ORVMoZSksIEFMTF9PTkVTKGYpLCBBTExfT05FUyhnKSwgQUxMX09O
RVMoaCksDQo+ID4gIAkJQUxMX09ORVMoaSksIEFMTF9PTkVTKGopKTsNCj4gDQo+IE9oIG9rLCBJ
IHNlZSB0aGUgaXNzdWUgbm93Lg0KPiANCj4gU28gdGhlIHByb2JsZW0gaXMgdGhhdCB0aGlzIHZh
bHVlIGdldHMgYmlnZ2VyIHRoYW4gd2hhdCB0aGUgbWF4aW1hbA0KPiB2YWx1ZSBmb3IgdGhlIHR5
cGUgcGFzc2VkIGFzIGFyZ3VtZW50IGlzIHN1cHBvc2VkIHRvIGJlLg0KPiANCj4gSSB0aGluayB0
aGUgaXNzdWUgaXMgY2xlYXIgbm93IGFuZCB3aHkgYSBkb3VibGUgY2FzdCBpcyBnb29kLg0KDQpJ
dCBpcyBtdWNoIGNsZWFyZXIgdG8ganVzdCB1c2UgMHhmZmZmLg0KQWx0aG91Z2ggYSBuYW1lZCAj
ZGVmaW5lIGNvbnN0YW50IGlzIG1vcmUgYXBwcm9wcmlhdGUNCmZvciB0aGUgY29kZSBpdHNlbGYu
DQoNCglEYXZpZA0K
