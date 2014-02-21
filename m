From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH V4 net-next 2/5] xen-netback: Add support for multiple
 queues
Date: Fri, 21 Feb 2014 13:16:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6C813A@AcuExch.aculab.com>
References: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com>
 <1392659880-2538-3-git-send-email-andrew.bennieston@citrix.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD0255316@AMSPEX01CL01.citrite.net>
 <53074490.8030806@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>
To: 'Andrew Bennieston' <andrew.bennieston@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40728 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755275AbaBUNRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 08:17:39 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12086-10 for <netdev@vger.kernel.org>;
 Fri, 21 Feb 2014 13:17:36 +0000 (GMT)
In-Reply-To: <53074490.8030806@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogT2YgQW5kcmV3ICBCZW5uaWVzdG9uDQo+ID4+ICsJY2hhciAqeHNwYXRoID0gTlVMTDsN
Cj4gPg0KPiA+IEkgZG9uJ3QgdGhpbmsgeW91IG5lZWQgdGhlIE5VTEwgaW5pdCBoZXJlLiB4c3Bh
dGggaXMgc2V0IGluIGJvdGggYnJhbmNoZXMgb2YgdGhlIGlmIHN0YXRlbWVudCBiZWxvdy4NCj4g
DQo+IEluZGVlZCwgYnV0IEkgcHJlZmVyIHRvIGluaXRpYWxpc2UgdGhpbmdzIHNhbmVseSB3aGVy
ZSBwb3NzaWJsZS4gSXQNCj4gbWFrZXMgaXQgZWFzaWVyIHRvIHNwb3QgcHJvYmxlbXMgd2l0aCBs
YXRlciBtb2RpZmljYXRpb25zIG9mIHRoZSBjb2RlLA0KPiBlLmcuIGlmIG9uZSBvZiB0aG9zZSBi
cmFuY2hlcyBjaGFuZ2VkLg0KDQpJZiB5b3UgZG9uJ3QgaW5pdGlhbGlzZSBpdCB0aGUgY29tcGls
ZXIgaXMgbGlrZWx5IHRvIGRldGVjdCB0aGUNCmZhY3QgdGhhbiBvbmUgY29kZSBwYXRoIGhhc24n
dCBzZXQgaXQuDQpJZiB5b3UgaW5pdGlhbGlzZSBpdCwgdGhlIGNvbXBpbGVyIGRvZXNuJ3QuDQoN
CglEYXZpZA0KDQo=
