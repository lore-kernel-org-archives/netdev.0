From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 07/17] fm10k: use an unsigned int for i in
 ethtool_get_strings
Date: Tue, 16 Jun 2015 20:33:00 +0000
Message-ID: <1434486780.12272.1.camel@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1434462448-140563-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <55803055.5030003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7823 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757132AbbFPUdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 16:33:04 -0400
In-Reply-To: <55803055.5030003@cogentembedded.com>
Content-Language: en-US
Content-ID: <6E1F19868033FE4888AC4BFBB85C411D@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE1LTA2LTE2IGF0IDE3OjE5ICswMzAwLCBTZXJnZWkgU2h0eWx5b3Ygd3JvdGU6
DQo+IE9uIDYvMTYvMjAxNSA0OjQ3IFBNLCBKZWZmIEtpcnNoZXIgd3JvdGU6DQo+IA0KPiA+IEZy
b206IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPg0KPiANCj4gPiBUaGUg
dmFsdWUgd2lsbCBuZXZlciBiZSBuZWdhdGl2ZSwgYW5kIHdlIHVzZSB0aGUgJWkgcHJpbnQgZm9y
bWF0LCANCj4gPiB1c2UNCj4gDQo+ICAgICAiJWkiIGlzIHRoZSBzYW1lIGFzICIlZCIsIEFGQUlS
LiBZb3UgbmVlZCAiJXUiIGZvciB0aGUgdW5zaWduZWQgDQo+IHZhcmlhYmxlcy4NCj4gDQo+ID4g
dW5zaWduZWQgaW50IGZvciB0aGUgbG9vcCBjb3VudGVyLiBJc3N1ZSBmb3VuZCB1c2luZyBjcHBj
aGVjay4NCj4gDQo+ID4gU2lnbmVkLW9mZi1ieTogSmFjb2IgS2VsbGVyIDxqYWNvYi5lLmtlbGxl
ckBpbnRlbC5jb20+DQo+ID4gVGVzdGVkLWJ5OiBLcmlzaG5laWwgU2luZ2ggPEtyaXNobmVpbC5r
LnNpbmdoQGludGVsLmNvbT4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBKZWZmIEtpcnNoZXIgPGplZmZy
ZXkudC5raXJzaGVyQGludGVsLmNvbT4NCj4gDQo+IFdCUiwgU2VyZ2VpDQo+IA0KDQpPb3BzLCB5
b3UgYXJlIHJpZ2h0Lg0KDQpSZWdhcmRzLA0KSmFrZQ==
