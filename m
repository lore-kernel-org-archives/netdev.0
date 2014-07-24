From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 03/14] ixgbe: fix use of list_for_each in
 ixgbe_enumerate_functions
Date: Thu, 24 Jul 2014 16:48:01 +0000
Message-ID: <1406220481.30819.1.camel@jekeller-desk1.amr.corp.intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1406207604-31653-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9024 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759449AbaGXQsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 12:48:03 -0400
In-Reply-To: <1406207604-31653-4-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Content-ID: <AA9E3F78D64E8D4EA75AB478C670EB8A@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE0LTA3LTI0IGF0IDA2OjEzIC0wNzAwLCBKZWZmIEtpcnNoZXIgd3JvdGU6DQo+
IEZyb206IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPg0KPiANCj4gRml4
IGEgYnVnIGluIHRoZSBtaXN1c2Ugb2YgdGhlIGxpc3RfZm9yX2VhY2ggbWFjcm8gdG8gbG9vcCBv
dmVyIGV2ZXJ5DQo+IGVudHJ5IGluIHRoZSBidXNfbGlzdC4gSW5zdGVhZCBvZiBhdHRlbXB0aW5n
IHRvIGxvb3Agb3ZlciB0aGUgbGlzdCBmcm9tDQo+IGEgcmFuZG9tIGVudHJ5IHBvaW50LCBnbyB1
cCB0byB0aGUgYnVzIGFuZCB1c2UgdGhlIHJlYWwgbGlzdF9oZWFkIGVudHJ5DQo+IHBvaW50LiBU
aGlzIHByZXZlbnRzIHRoZSBwb3NzaWJsZSByZWFkIG9yIHdyaXRlIG9mIHVuYWxsb2NhdGVkIG9y
DQo+IGluY29ycmVjdGx5IGFkZHJlc3NlZCBtZW1vcnkuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBK
YWNvYiBLZWxsZXIgPGphY29iLmUua2VsbGVyQGludGVsLmNvbT4NCj4gVGVzdGVkLWJ5OiBQaGls
IFNjaG1pdHQgPHBoaWxsaXAuai5zY2htaXR0QGludGVsLmNvbT4NCj4gU2lnbmVkLW9mZi1ieTog
SmVmZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5jb20+DQo+IC0tLQ0KDQpSZWFs
aXplZCBJIGZvcmdvdCB0byBhZGQsIGZvciB0aG9zZSB0aGF0IG1pZ2h0IGJlIGludGVyZXN0ZWQg
KHN0YWJsZQ0Ka2VybmVsIG1haW50YWluZXJzPykNCg0KRml4ZXM6IGUwMjdkMWFlYzRiYiAoIml4
Z2JlOiBjYWxsIHBjaWVfZ2V0X21pbWltdW1fbGluayB0byBjaGVjayBpZiBkZXZpY2UgaGFzIGVu
b3VnaCBiYW5kd2lkdGgiKQ0KDQpUaGFua3MsDQpKYWtlDQo=
