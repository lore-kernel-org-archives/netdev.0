From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [RFC PATCH 2/7] net: ethernet: update drivers to handle
 HWTSTAMP_FILTER_NTP_ALL
Date: Thu, 13 Apr 2017 09:00:01 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857E00E6E@ORSMSX115.amr.corp.intel.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
 <20170412141737.5881-3-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:27720 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdDMJAC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 05:00:02 -0400
In-Reply-To: <20170412141737.5881-3-mlichvar@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogTWlyb3NsYXYgTGljaHZh
ciBbbWFpbHRvOm1saWNodmFyQHJlZGhhdC5jb21dDQo+IFNlbnQ6IFdlZG5lc2RheSwgQXByaWwg
MTIsIDIwMTcgNzoxOCBBTQ0KPiBUbzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPiBDYzogUmlj
aGFyZCBDb2NocmFuIDxyaWNoYXJkY29jaHJhbkBnbWFpbC5jb20+OyBXaWxsZW0gZGUgQnJ1aWpu
DQo+IDx3aWxsZW1iQGdvb2dsZS5jb20+OyBTb2hlaWwgSGFzc2FzIFllZ2FuZWggPHNvaGVpbEBn
b29nbGUuY29tPjsgS2VsbGVyLA0KPiBKYWNvYiBFIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+
OyBEZW5ueSBQYWdlIDxkZW5ueXBhZ2VAbWUuY29tPjsgSmlyaQ0KPiBCZW5jIDxqYmVuY0ByZWRo
YXQuY29tPg0KPiBTdWJqZWN0OiBbUkZDIFBBVENIIDIvN10gbmV0OiBldGhlcm5ldDogdXBkYXRl
IGRyaXZlcnMgdG8gaGFuZGxlDQo+IEhXVFNUQU1QX0ZJTFRFUl9OVFBfQUxMDQo+IA0KPiBVcGRh
dGUgZHJpdmVycyB3aGljaCBjYW4gdGltZXN0YW1wIGFsbCBwYWNrZXRzIHRvIGhhbmRsZSBhbHNv
DQo+IEhXVFNUQU1QX0ZJTFRFUl9OVFBfQUxMLg0KPiANCg0KVGhlIGNvZGUgbG9va3Mgb2sgdG8g
bWUsIHRob3VnaCBJIGFncmVlIHdpdGggUmljaGFyZCB0aGF0IHRoZSBkZXNjcmlwdGlvbiBzaG91
bGQgYmUgbW9yZSBjbGVhciB0aGF0IG5vdCBhbGwgbG9jYXRpb25zIGFyZSBhYm91dCBzdXBwb3J0
aW5nIHRoZSBuZXcgZmVhdHVyZSAoc2luY2UgbWFueSBsb2NhdGlvbnMgZG9uJ3QgYWN0dWFsbHkg
c3VwcG9ydCBBTEwgYnV0IG1lcmVseSBlcnJvciBvdXQpDQoNClRoYW5rcywNCkpha2UNCg0K
