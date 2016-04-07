From: "Waskiewicz, PJ" <PJ.Waskiewicz@netapp.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Thu, 7 Apr 2016 19:48:50 +0000
Message-ID: <1460058531.13579.12.camel@netapp.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bblanco@plumgrid.com" <bblanco@plumgrid.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"tom@herbertland.com" <tom@herbertland.com>,
	"lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>
To: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"brouer@redhat.com" <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:12126 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755300AbcDGTsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 15:48:53 -0400
In-Reply-To: <20160407161715.52635cac@redhat.com>
Content-Language: en-US
Content-ID: <A66DB2D3F274B84D9660316A70387620@hq.netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE2LTA0LTA3IGF0IDE2OjE3ICswMjAwLCBKZXNwZXIgRGFuZ2FhcmQgQnJvdWVy
IHdyb3RlOg0KPiAoVG9waWMgcHJvcG9zYWwgZm9yIE1NLXN1bW1pdCkNCj4gDQo+IE5ldHdvcmsg
SW50ZXJmYWNlIENhcmRzIChOSUMpIGRyaXZlcnMsIGFuZCBpbmNyZWFzaW5nIHNwZWVkcyBzdHJl
c3MNCj4gdGhlIHBhZ2UtYWxsb2NhdG9yIChhbmQgRE1BIEFQSXMpLsKgwqBBIG51bWJlciBvZiBk
cml2ZXIgc3BlY2lmaWMNCj4gb3Blbi1jb2RlZCBhcHByb2FjaGVzIGV4aXN0cyB0aGF0IHdvcmst
YXJvdW5kIHRoZXNlIGJvdHRsZW5lY2tzIGluDQo+IHRoZQ0KPiBwYWdlIGFsbG9jYXRvciBhbmQg
RE1BIEFQSXMuIEUuZy4gb3Blbi1jb2RlZCByZWN5Y2xlIG1lY2hhbmlzbXMsIGFuZA0KPiBhbGxv
Y2F0aW5nIGxhcmdlciBwYWdlcyBhbmQgaGFuZGluZy1vdXQgcGFnZSAiZnJhZ21lbnRzIi4NCj4g
DQo+IEknbSBwcm9wb3NpbmcgYSBnZW5lcmljIHBhZ2UtcG9vbCByZWN5Y2xlIGZhY2lsaXR5LCB0
aGF0IGNhbiBjb3Zlcg0KPiB0aGUNCj4gZHJpdmVyIHVzZS1jYXNlcywgaW5jcmVhc2UgcGVyZm9y
bWFuY2UgYW5kIG9wZW4gdXAgZm9yIHplcm8tY29weSBSWC4NCg0KSXMgdGhpcyBiYXNlZCBvbiB0
aGUgcGFnZSByZWN5Y2xlIHN0dWZmIGZyb20gaXhnYmUgdGhhdCB1c2VkIHRvIGJlIGluDQp0aGUg
ZHJpdmVyPyDCoElmIHNvIEknZCByZWFsbHkgbGlrZSB0byBiZSBwYXJ0IG9mIHRoZSBkaXNjdXNz
aW9uLg0KDQotUEoNCg0KDQotLSANClBKIFdhc2tpZXdpY3oNClByaW5jaXBhbCBFbmdpbmVlciwg
TmV0QXBwDQplOiBwai53YXNraWV3aWN6QG5ldGFwcC5jb20NCmQ6IDUwMy45NjEuMzcwNQ0K
