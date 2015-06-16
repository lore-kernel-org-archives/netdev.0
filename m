From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 07/17] fm10k: use an unsigned int for i in
 ethtool_get_strings
Date: Tue, 16 Jun 2015 20:37:56 +0000
Message-ID: <1434487076.12272.3.camel@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1434462448-140563-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <55803055.5030003@cogentembedded.com> <1434486780.12272.1.camel@intel.com>
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
Received: from mga09.intel.com ([134.134.136.24]:48010 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916AbbFPUh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 16:37:59 -0400
In-Reply-To: <1434486780.12272.1.camel@intel.com>
Content-Language: en-US
Content-ID: <FB128A36A1CEA64D954545ED18C4E574@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE1LTA2LTE2IGF0IDEzOjMzIC0wNzAwLCBKYWNvYiBFIEtlbGxlciB3cm90ZToN
Cj4gT24gVHVlLCAyMDE1LTA2LTE2IGF0IDE3OjE5ICswMzAwLCBTZXJnZWkgU2h0eWx5b3Ygd3Jv
dGU6DQo+ID4gT24gNi8xNi8yMDE1IDQ6NDcgUE0sIEplZmYgS2lyc2hlciB3cm90ZToNCj4gPiAN
Cj4gPiA+IEZyb206IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPg0KPiA+
IA0KPiA+ID4gVGhlIHZhbHVlIHdpbGwgbmV2ZXIgYmUgbmVnYXRpdmUsIGFuZCB3ZSB1c2UgdGhl
ICVpIHByaW50IGZvcm1hdCwgDQo+ID4gPiANCj4gPiA+IHVzZQ0KPiA+IA0KPiA+ICAgICAiJWki
IGlzIHRoZSBzYW1lIGFzICIlZCIsIEFGQUlSLiBZb3UgbmVlZCAiJXUiIGZvciB0aGUgdW5zaWdu
ZWQgDQo+ID4gDQo+ID4gdmFyaWFibGVzLg0KPiA+IA0KPiA+ID4gdW5zaWduZWQgaW50IGZvciB0
aGUgbG9vcCBjb3VudGVyLiBJc3N1ZSBmb3VuZCB1c2luZyBjcHBjaGVjay4NCj4gPiANCj4gPiA+
IFNpZ25lZC1vZmYtYnk6IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPg0K
PiA+ID4gVGVzdGVkLWJ5OiBLcmlzaG5laWwgU2luZ2ggPEtyaXNobmVpbC5rLnNpbmdoQGludGVs
LmNvbT4NCj4gPiA+IFNpZ25lZC1vZmYtYnk6IEplZmYgS2lyc2hlciA8amVmZnJleS50LmtpcnNo
ZXJAaW50ZWwuY29tPg0KPiA+IA0KPiA+IFdCUiwgU2VyZ2VpDQo+ID4gDQo+IA0KPiBPb3BzLCB5
b3UgYXJlIHJpZ2h0Lg0KPiANCj4gUmVnYXJkcywNCj4gSmFrZQ0KDQpUaGUgYWN0dWFsIGNvZGUg
ZG9lcyB1c2UgJXUsIGJ1dCBJIG1hZGUgYSB0eXBvIGluIHRoZSBkZXNjcmlwdGlvbi4gSSBhbQ0K
c2VuZGluZyBhbiByYzIuDQoNClJlZ2FyZHMsDQpKYWtl
