From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] ixgbe: always initialize setup_fc
Date: Mon, 11 Jul 2016 18:41:40 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250670DA6@FMSMSX105.amr.corp.intel.com>
References: <CAE2NFgXEYU0mJDs638JYzykUSz4PCme6kecXVjWesH=0ySxZVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Patrick McLean <patrickm@gaikai.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4137 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbcGKSlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 14:41:42 -0400
In-Reply-To: <CAE2NFgXEYU0mJDs638JYzykUSz4PCme6kecXVjWesH=0ySxZVQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogSW50ZWwtd2lyZWQtbGFuIFttYWls
dG86aW50ZWwtd2lyZWQtbGFuLWJvdW5jZXNAbGlzdHMub3N1b3NsLm9yZ10gT24NCj5CZWhhbGYg
T2YgUGF0cmljayBNY0xlYW4NCj5TZW50OiBGcmlkYXksIEp1bHkgMDEsIDIwMTYgNjozMSBQTQ0K
PlRvOiBLaXJzaGVyLCBKZWZmcmV5IFQgPGplZmZyZXkudC5raXJzaGVyQGludGVsLmNvbT4NCj5D
YzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgaW50ZWwtd2lyZWQtbGFuQGxpc3RzLm9zdW9zbC5v
cmcNCj5TdWJqZWN0OiBbSW50ZWwtd2lyZWQtbGFuXSBbUEFUQ0hdIGl4Z2JlOiBhbHdheXMgaW5p
dGlhbGl6ZSBzZXR1cF9mYw0KPg0KPkluIGl4Z2JlX2luaXRfbWFjX2xpbmtfb3BzX1g1NTBlbSwg
dGhlIGNvZGUgaGFzIGEgc3BlY2lhbCBjYXNlIGZvcg0KPmJhY2twbGFuZSBtZWRpYSB0eXBlLCBi
dXQgZG9lcyBub3QgZmFsbCB0aHJvdWdoIHRvIHRoZSBkZWZhdWx0IGNhc2UsIHNvIHRoZQ0KPnNl
dHVwX2ZjIG5ldmVyIGdldHMgaW5pdGlhbGl6ZWQuIFRoaXMgY2F1c2VzIGEgcGFuaWMgd2hlbiBp
dCBsYXRlciB0cmllcyB0bw0KPnNldCB1cCB0aGUgY2FyZCwgYW5kIHRoZSBrZXJuZWwgZGVyZWZl
cmVuY2VzIHRoZSBudWxsIHBvaW50ZXIuDQo+DQo+VGhpcyBwYXRjaCBsZXRzIHRoZSB0aGUgZnVu
Y3Rpb24gZmFsbCB0aHJvdWdoLCB3aGljaCBpbml0aWFsaXplZCBzZXR1cF9mYw0KPnByb3Blcmx5
Lg0KDQpXaHkgYXJlIHlvdSByZXNlbmRpbmcgdGhpcyBwYXRjaD8gSSBoYXZlIGFscmVhZHkgc3Vi
bWl0dGVkIGEgcGF0Y2ggdG8gaGFuZGxlIHRoaXMgcHJvcGVybHk6DQpodHRwOi8vcGF0Y2h3b3Jr
Lm96bGFicy5vcmcvcGF0Y2gvNjQ2MjI4Lw0KDQpUaGFua3MsDQpFbWlsIA0KIA0KDQo=
