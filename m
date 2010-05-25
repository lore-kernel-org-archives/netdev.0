From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: ixgbe: macvlan on PF/VF when SRIOV is enabled
Date: Tue, 25 May 2010 10:08:41 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755A7A58C58@orsmsx508.amr.corp.intel.com>
References: <1274473846.8701.25.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A79C099C@orsmsx508.amr.corp.intel.com>
	 <1274720919.18023.19.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A79C0E05@orsmsx508.amr.corp.intel.com>
	 <1274780239.18023.48.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A7A58B5F@orsmsx508.amr.corp.intel.com>
 <1274806289.18023.57.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16942 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754277Ab0EYRIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 13:08:44 -0400
In-Reply-To: <1274806289.18023.57.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogU2hpcmxleSBNYSBbbWFpbHRvOm1h
c2hpcmxlQHVzLmlibS5jb21dDQo+U2VudDogVHVlc2RheSwgTWF5IDI1LCAyMDEwIDk6NTEgQU0N
Cj5UbzogUm9zZSwgR3JlZ29yeSBWDQo+Q2M6IEtpcnNoZXIsIEplZmZyZXkgVDsgZGF2ZW1AZGF2
ZW1sb2Z0Lm5ldDsga3ZtQHZnZXIua2VybmVsLm9yZzsNCj5uZXRkZXZAdmdlci5rZXJuZWwub3Jn
OyBlMTAwMC1kZXZlbEBsaXN0cy5zb3VyY2Vmb3JnZS5uZXQNCj5TdWJqZWN0OiBSRTogaXhnYmU6
IG1hY3ZsYW4gb24gUEYvVkYgd2hlbiBTUklPViBpcyBlbmFibGVkDQo+DQo+T24gVHVlLCAyMDEw
LTA1LTI1IGF0IDA4OjU3IC0wNzAwLCBSb3NlLCBHcmVnb3J5IFYgd3JvdGU6DQo+PiBKdXN0IHVz
ZSBpZmNvbmZpZyBhbmQgdmNvbmZpZyB1dGlsaXRpZXMgdG8gc2V0IHRoZSBNQUMgYW5kIFZMQU4g
Zm9yDQo+PiBlYWNoIFZGLiAgVGhlcmUgc2hvdWxkbid0IGJlIGFueSBuZWVkIGZvciBzZWNvbmRh
cnkgYWRkcmVzc2VzIGJlY2F1c2UNCj4+IHRoZXkncmUgbm90IGxpa2UgcGh5c2ljYWwgZGV2aWNl
cyB3aGVyZSBlYWNoIFZGIGhhcyBhIHByZS1wcm9ncmFtbWVkDQo+PiBIVyBNQUMgYWRkcmVzcy4g
IFRoZSBpbml0aWFsIE1BQyBhZGRyZXNzIG9mIGVhY2ggVkYgaXMgZ2VuZXJhdGVkIG9uDQo+PiB0
aGUgZmx5IGR1cmluZyB0aGUgUEYgZHJpdmVyIGluaXRpYWxpemF0aW9uLiBZb3UgY2FuIGNoYW5n
ZSBpdCBhcyB5b3UNCj4+IHNlZSBmaXQgYW5kIHRoZW4gcHV0IHRoZSBWRiBvbiBhIFZMQU4gdXNp
bmcgdmNvbmZpZy4gIEFmdGVyIHlvdSBkbw0KPj4gdGhhdCB5b3UgaGF2ZSBhIG1hY3ZsYW4gZmls
dGVyIGZvciB0aGF0IFZGLg0KPg0KPkkgcnVuIG1hY3ZsYW4gdGVzdCBub3Qgdmxhbi4gbWFjdmxh
biBpcyB1c2VkIHRvIGdpdmUgYSBzZWNvbmQgTUFDDQo+YWRkcmVzcyB0byBhIG5ldHdvcmsgYWRh
cHRlciBhbmQgc2VlIGl0IGFzIGEgbmV3IGRldmljZSBhdCB0aGUgaGlnaGVyDQo+bGV2ZWxzLiBU
aGUgY29tbWFuZCBpcyB1c2VkIGFzIGZvbGxvdzoNCj4NCj5pcCBsaW5rIGFkZCBsaW5rIGV0aDQg
YWRkcmVzcyA1NDo1MjowMDozNTplMzoyMCBtYWN2bGFuMiB0eXBlIG1hY3ZsYW4NCj4NCj5JdCB3
aWxsIGNyZWF0ZSBhbiBpbnRlcmZhY2UgbmFtZSBtYWN2bGFuMiB3aXRoIGFib3ZlIE1BQyBhZGRy
ZXNzLiBJbg0KPmtlcm5lbCwgbmV0ZGV2IGV0aDQgbWFpbnRhaW5zIHRoaXMgc2Vjb25kYXJ5IGFk
ZHJlc3MuDQoNClJpZ2h0LCBzbyB3aGF0IEknbSBzYXlpbmcgaXMgdGhhdCBpZiB5b3UgbG9hZCB0
aGUgVkYgZHJpdmVyIGl0IHdpbGwgY3JlYXRlIGFuZCA8ZXRoPiBpbnRlcmZhY2UgZm9yIGVhY2gg
VkYgeW91J3ZlIGNyZWF0ZWQuICBZb3UgY2FuIGFzc2lnbiBhIE1BQyBhbmQgVkxBTiB0byB0aGF0
IDxldGg+IGludGVyZmFjZSBhbmQgd2lsbCBnZXQgZXNzZW50aWFsbHkgdGhlIHNhbWUgYmVoYXZp
b3IuDQoNCi0gR3JlZw0KDQo=
