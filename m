From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: RE: [PATCH 1/4] pch_gbe: fix the checksum fill to the error location
Date: Tue, 10 Jul 2012 08:28:15 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44D011051CC@ka-exchange-1.kontronamerica.local>
References: <40680C535D6FE6498883F1640FACD44D010BFC0F@ka-exchange-1.kontronamerica.local> <1341864963.2535.55.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:48027 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab2GJP2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:28:16 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1341864963.2535.55.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WWVzLCB0aGlzIG5lZWRzIHJld29yayB0byB1c2UgdGhlIHN0YW5kYXJkIHJv
dXRpbmUuDQpUaGFua3MgZm9yIHRoZSBpbnB1dC4NCg0KQW5keQ0KDQotLS0t
LU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KRnJvbTogQmVuIEh1dGNoaW5ncyBb
bWFpbHRvOmJodXRjaGluZ3NAc29sYXJmbGFyZS5jb21dIA0KU2VudDogTW9u
ZGF5LCBKdWx5IDA5LCAyMDEyIDQ6MTYgUE0NClRvOiBBbmR5IENyZXNzDQpD
YzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KU3ViamVjdDogUmU6IFtQQVRD
SCAxLzRdIHBjaF9nYmU6IGZpeCB0aGUgY2hlY2tzdW0gZmlsbCB0byB0aGUg
ZXJyb3IgbG9jYXRpb24NCg0KT24gTW9uLCAyMDEyLTA3LTA5IGF0IDA2OjMw
IC0wNzAwLCBBbmR5IENyZXNzIHdyb3RlOg0KPiBGcm9tOiBaaG9uZyBIb25n
Ym8gPGhvbmdiby56aG9uZ0B3aW5kcml2ZXIuY29tPg0KPiBEYXRlOiBNb24s
IDkgQXByIDIwMTIgMTA6NTE6MjggKzA4MDANCj4gDQpbLi4uXQ0KPg0KPiBX
ZSBjYW4gZml4IHRoaXMgaXNzdWUgYnkgbWFudWFsbHkgY2FsY3VsYXRlIHRo
ZSBvZmZzZXQgb2YgdGhlIFRDUA0KPiBjaGVja3N1bQ0KPiAgYW5kIHVwZGF0
ZSBpdCBhY2NvcmRpbmdseS4NClsuLi5dDQoNCllvdSBzaG91bGQgYmUgdXNp
bmcgc2tiX2NoZWNrc3VtX3N0YXJ0X29mZnNldCgpIGluc3RlYWQuDQoNCkJl
bi4NCg0KDQo=
