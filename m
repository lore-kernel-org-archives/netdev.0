From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [RFC PATCH 4/7] net: ethernet: update drivers to provide
 timestamping packet info
Date: Thu, 13 Apr 2017 09:04:21 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857E00E99@ORSMSX115.amr.corp.intel.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
 <20170412141737.5881-5-mlichvar@redhat.com>
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
Received: from mga04.intel.com ([192.55.52.120]:38533 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751276AbdDMJEW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 05:04:22 -0400
In-Reply-To: <20170412141737.5881-5-mlichvar@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBNaXJvc2xhdiBMaWNodmFyIFtt
YWlsdG86bWxpY2h2YXJAcmVkaGF0LmNvbV0NCj4gU2VudDogV2VkbmVzZGF5LCBBcHJpbCAxMiwg
MjAxNyA3OjE4IEFNDQo+IFRvOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IENjOiBSaWNoYXJk
IENvY2hyYW4gPHJpY2hhcmRjb2NocmFuQGdtYWlsLmNvbT47IFdpbGxlbSBkZSBCcnVpam4NCj4g
PHdpbGxlbWJAZ29vZ2xlLmNvbT47IFNvaGVpbCBIYXNzYXMgWWVnYW5laCA8c29oZWlsQGdvb2ds
ZS5jb20+OyBLZWxsZXIsDQo+IEphY29iIEUgPGphY29iLmUua2VsbGVyQGludGVsLmNvbT47IERl
bm55IFBhZ2UgPGRlbm55cGFnZUBtZS5jb20+OyBKaXJpDQo+IEJlbmMgPGpiZW5jQHJlZGhhdC5j
b20+DQo+IFN1YmplY3Q6IFtSRkMgUEFUQ0ggNC83XSBuZXQ6IGV0aGVybmV0OiB1cGRhdGUgZHJp
dmVycyB0byBwcm92aWRlIHRpbWVzdGFtcGluZw0KPiBwYWNrZXQgaW5mbw0KPiANCj4gVXBkYXRl
IGRyaXZlcnMgdGhhdCBzdXBwb3J0IGhhcmR3YXJlIHRpbWVzdGFtcGluZyB0byBwcm92aWRlIHRo
ZQ0KPiBpbnRlcmZhY2UgaW5kZXggYW5kIHBhY2tldCBsZW5ndGggZm9yIHRoZSBTT0ZfVElNRVNU
QU1QSU5HX09QVF9QS1RJTkZPDQo+IG9wdGlvbi4NCj4gDQo+IFRPRE86IHVwZGF0ZSBvdGhlciBk
cml2ZXJzIChub3QganVzdCBlMTAwMGUgYW5kIGlnYikNCj4gDQo+IENDOiBSaWNoYXJkIENvY2hy
YW4gPHJpY2hhcmRjb2NocmFuQGdtYWlsLmNvbT4NCj4gQ0M6IFdpbGxlbSBkZSBCcnVpam4gPHdp
bGxlbWJAZ29vZ2xlLmNvbT4NCj4gQ0M6IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50
ZWwuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBNaXJvc2xhdiBMaWNodmFyIDxtbGljaHZhckByZWRo
YXQuY29tPg0KPiAtLS0NCg0KRHJpdmVyIGNoYW5nZXMgc2VlbSBhbHJpZ2h0IHRvIG1lLiBJIG1p
Z2h0IGhhdmUgZ29uZSBhIGRpZmZlcmVudCByb3V0ZSB3aXRob3V0IGNoYW5naW5nIHRoZSByZXR1
cm4gdmFsdWUgb2YgZnVuY3Rpb25zIGJ1dCBpdCBkb2Vzbid0IG1ha2UgYSBodWdlIGRpZmZlcmVu
Y2UsIGFuZCBpIGd1ZXNzIHRoaXMgcm91dGUgaXMgZWFzaWVyIHRvIGZvbGxvdyB0aGUgY29kZS4N
Cg0KVGhhbmtzLA0KSmFrZQ0KDQo=
