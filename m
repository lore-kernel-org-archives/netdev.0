From: CLOSE Dave <Dave.Close@us.thalesgroup.com>
Subject: Re: Trying to ping from a subinterface.
Date: Tue, 3 Jun 2014 09:29:45 -0700
Message-ID: <538DF7F9.4020306@us.thalesgroup.com>
References: <538CE2CA.9060806@us.thalesgroup.com>
 <20140602173554.1dc77101@nehalam.linuxnetplumber.net>
 <538D19C9.3090801@us.thalesgroup.com> <538D4B7F.4080302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: Ben Greear <greearb@candelatech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thsbbuxrt02p.us.thalesgroup.com ([192.93.163.26]:31825 "EHLO
	thsbbuxrt02p.us.thalesgroup.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933126AbaFCQfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 12:35:30 -0400
Received: from thsbbuxrt02p.us.thalesgroup.com (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 6DF9570007D
	for <netdev@vger.kernel.org>; Tue,  3 Jun 2014 12:34:57 -0400 (EDT)
Received: from thsbbuirt02p.us.thales (unknown [10.95.3.16])
	by thsbbuxrt02p.us.thalesgroup.com (Postfix) with ESMTP id 54A9270005A
	for <netdev@vger.kernel.org>; Tue,  3 Jun 2014 12:34:57 -0400 (EDT)
Received: from THSBBUIAV02P.us.thales (mcafee2.us.thales [10.95.3.12])
	by thsbbuirt02p.us.thales (Postfix) with ESMTPS id 1C1F420001F
	for <netdev@vger.kernel.org>; Tue,  3 Jun 2014 12:35:22 -0400 (EDT)
In-Reply-To: <538D4B7F.4080302@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SSB3cm90ZToNCg0KPiBJIGFwb2xvZ2l6ZSB0byB0aGUgZ3JvdXAuIEkgaGFkIGJlZW4gbGVkIHRv
IGJlbGlldmUgdGhpcyB3YXMgd29ya2luZyBvbg0KPiBlYXJsaWVyIEZlZG9yYSByZWxlYXNlcy4g
SW4gZmFjdCwgaXQgd2FzIGNvbXBsYWluaW5nIGJ1dCB0aGVuIGZhbGxpbmcNCj4gYmFjayB0byB0
aGUgbWFpbiBpbnRlcmZhY2UgYW5kIHBlcmZvcm1pbmcgdGhlIHBpbmcgYW55d2F5LiBXaGF0IGlz
IG5ldw0KPiBpcyB0aGUgcmVmdXNhbCB0byBmYWxsIGJhY2suDQoNCkJlbiBHcmVlYXIgYW5zd2Vy
ZWQ6DQoNCj4gU09fQklORFRPREVWSUNFIGNvdWxkIG5ldmVyIHdvcmsgb24gc3ViLWludGVyZmFj
ZXMgYXMgZmFyIGFzIEkga25vdywNCj4gYnV0IG1heWJlIG9sZGVyIHZlcnNpb25zIG9mIHBpbmcg
anVzdCBkaWRuJ3QgYm90aGVyIGRvaW5nIFNPX0JJTkRUT0RFVklDRS4NCg0KSXQgYXBwZWFycyB0
aGF0IHRoZSBvbGRlciB2ZXJzaW9uIHRyaWVkIHRoZSBjYWxsLCBnb3QgYSBmYWlsdXJlLA0KY29t
cGxhaW5lZCBhYm91dCBpdCwgYW5kIHRoZW4gY29udGludWVkIGJ5IHVzaW5nIHRoZSBtYWluIGlu
dGVyZmFjZQ0KaW5zdGVhZC4gVGhlIGV4aXQgY29kZSB3YXMgbm90IGFmZmVjdGVkLg0KDQpUaGUg
Y3VycmVudCB2ZXJzaW9uIHRyaWVzIHRoZSBjYWxsLCBmYWlscywgY29tcGxhaW5zLCBhbmQgZXhp
dHMgd2l0aA0KY29kZSAyLg0KDQo+IERvIHlvdSBhY3R1YWxseSBuZWVkIHN1Yi1pbnRlcmZhY2Vz
IGZvciBzb21lIHJlYXNvbiwgb3IgY2FuIHlvdSBqdXN0IHVzZQ0KPiBtdWx0aXBsZSBJUHMgb24g
b25lIGludGVyZmFjZSAob3IgbWF5YmUgbWFjLXZsYW5zKT8NCg0KSSBjYW4gbGl2ZSB3aXRob3V0
IHRoZW0uIEJ1dCB0aGV5IGRvIHByb3ZpZGUgYSBuaWNlIHdheSB0byByZWZlcmVuY2UNCmFuIGFk
ZHJlc3MgYnkgbmFtZS4NCi0tIA0KRGF2ZSBDbG9zZQ==
