From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next v10 3/7] ixgbe: Add a RETA
 query command to VF-PF channel API
Date: Tue, 31 Mar 2015 23:55:42 +0000
Message-ID: <87618083B2453E4A8714035B62D67992502896D2@FMSMSX105.amr.corp.intel.com>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
 <1427740529-9605-4-git-send-email-vladz@cloudius-systems.com>
 <1427787327.2497.111.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27947 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058AbbCaXzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 19:55:51 -0400
In-Reply-To: <1427787327.2497.111.camel@jtkirshe-mobl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogSW50ZWwtd2lyZWQtbGFuIFttYWls
dG86aW50ZWwtd2lyZWQtbGFuLWJvdW5jZXNAbGlzdHMub3N1b3NsLm9yZ10gT24gQmVoYWxmIE9m
IEplZmYgS2lyc2hlcg0KPlNlbnQ6IFR1ZXNkYXksIE1hcmNoIDMxLCAyMDE1IDEyOjM1IEFNDQo+
U3ViamVjdDogUmU6IFtJbnRlbC13aXJlZC1sYW5dIFtQQVRDSCBuZXQtbmV4dCB2MTAgMy83XSBp
eGdiZTogQWRkIGEgUkVUQSBxdWVyeSBjb21tYW5kIHRvIFZGLVBGIGNoYW5uZWwgQVBJDQo+DQo+
T24gTW9uLCAyMDE1LTAzLTMwIGF0IDIxOjM1ICswMzAwLCBWbGFkIFpvbG90YXJvdiB3cm90ZToN
Cj4+IEFkZCB0aGlzIG5ldyBjb21tYW5kIGZvciA4MjU5OSBhbmQgeDU0MCBkZXZpY2VzIG9ubHku
IFN1cHBvcnQgZm9yDQo+PiBvdGhlciBkZXZpY2VzDQo+PiB3aWxsIGJlIGFkZGVkIGxhdGVyLg0K
Pj4gDQo+PiA4MjU5OSBhbmQgeDU0MCBWRnMgYW5kIFBGIHNoYXJlIHRoZSBzYW1lIFJTUyByZWRp
cmVjdGlvbiB0YWJsZSAoUkVUQSkuDQo+PiBUaGVyZWZvcmUgd2UganVzdCByZXR1cm4gaXQgZm9y
IGFsbCBWRnMuDQo+PiANCj4+IEZvciA4MjU5OSBhbmQgeDU0MCBSRVRBIHRhYmxlIGlzIGFuIGFy
cmF5IG9mIDMyIHJlZ2lzdGVycyAoMTI4IGJ5dGVzKQ0KPj4gYW5kIHRoZSBtYXhpbXVtIG51bWJl
ciBvZiByZWdpc3RlcnMgdGhhdCBtYXkgYmUgZGVsaXZlcmVkIGluIGEgc2luZ2xlIFZGLVBGIGNo
YW5uZWwgY29tbWFuZCBpcw0KPj4gMTUuIFRoZXJlZm9yZSB3ZSB3aWxsIGRlbGl2ZXIgdGhlIHdo
b2xlIHRhYmxlIGluIDMgc3RlcHM6IDEyLCAxMiBhbmQgOCByZWdpc3RlcnMgaW4NCj4+IGVhY2gg
c3RlcCBjb3JyZXNwb25kaW5nbHkuDQoNClRoZSBhYm92ZSBwYXJhZ3JhcGggbm8gbG9uZ2VyIGFw
cGxpZXMgdG8gdGhpcyBwYXRjaC4gUGVyaGFwcyBKZWZmIGNhbiBzdHJpcCBpdCB0byBhdm9pZCBo
YXZpbmcgdG8gcmVzZW5kIHRoZSANCnBhdGNoIGp1c3QgZm9yIHRoZSBkZXNjcmlwdGlvbi4NCg0K
VGhhbmtzLA0KRW1pbA0KDQo=
