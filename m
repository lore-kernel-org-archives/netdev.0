From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH 1/2] ethtool: add dynamic flag to ETHTOOL_{GS}RXFH
 commands
Date: Fri, 5 Feb 2016 16:42:40 +0000
Message-ID: <1454690560.3349.1.camel@intel.com>
References: <1454455328-706-2-git-send-email-jacob.e.keller@intel.com>
	 <20160204.175326.492457129636004051.davem@davemloft.net>
	 <1454627396.3086.14.camel@intel.com>
	 <20160204.193055.2172651314284452037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	"mcarlson@broadcom.com" <mcarlson@broadcom.com>,
	"yuvalmin@broadcom.com" <yuvalmin@broadcom.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"_govind@gmx.com" <_govind@gmx.com>,
	"Lendacky@vger.kernel.org" <Lendacky@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>,
	"hariprasad@chelsio.com" <hariprasad@chelsio.com>,
	"kalesh.purayil@emulex.com" <kalesh.purayil@emulex.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"Wyborny, Carolyn" <carolyn.wyb
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3298 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692AbcBEQmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 11:42:46 -0500
In-Reply-To: <20160204.193055.2172651314284452037.davem@davemloft.net>
Content-Language: en-US
Content-ID: <5700C3BA13B30641BF9EB79AE65193D9@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE2LTAyLTA0IGF0IDE5OjMwIC0wNTAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206ICJLZWxsZXIsIEphY29iIEUiIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+DQo+IERh
dGU6IFRodSwgNCBGZWIgMjAxNiAyMzowOTo1NiArMDAwMA0KPiANCj4gPiBTbyB5b3UncmUgc3Vn
Z2VzdGluZyBpbnN0ZWFkLCB0byBlcnJvciB3aGVuIHRoZSBzZWNvbmQgb3BlcmF0aW9uDQo+ID4g
KGNoYW5nZSBudW1iZXIgb2YgcXVldWVzKSB3b3VsZCBmYWlsIHRoZSBjdXJyZW50IHNldHRpbmdz
Pw0KPiANCj4gWWVzLg0KPiANCj4gVGhpcyBpcyBhYnNvbHV0ZWx5IHJlcXVpcmVkLg0KDQpJIHdp
bGwgaW52ZXN0aWdhdGUgdGhpcyByb3V0ZS4gSSB0aGluayB0aGVyZSBuZWVkcyB0byBzb21lIHdh
eSBmb3IgdGhlDQp7R1N9UlhGSCB0byBwYXNzIGVub3VnaCBpbmZvcm1hdGlvbiBpbiBhIHdheSB0
aGUgZHJpdmVyIGNhbiBjbGVhcmx5IHNlZQ0KYXMgInJlc2V0IHRvIGRlZmF1bHQiLCBidXQgb3Ro
ZXJ3aXNlIEkgdGhpbmsgdGhpcyBpcyBwcmV0dHkgc3RyYWlnaHQNCmZvcndhcmQgdG8gaW1wbGVt
ZW50Lg0KDQpUaGFua3MsDQpKYWtl
