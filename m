From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH 2/3] missing rtnl_unlock in igb_sriov_reinit()
Date: Tue, 4 Aug 2015 22:41:21 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81ADF4C9@ORSMSX101.amr.corp.intel.com>
References: <559BF609.4020705@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>
To: Vasily Averin <vvs@virtuozzo.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:35922 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383AbbHDWl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 18:41:28 -0400
In-Reply-To: <559BF609.4020705@virtuozzo.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVy
QHZnZXIua2VybmVsLm9yZ10NCj4gT24gQmVoYWxmIE9mIFZhc2lseSBBdmVyaW4NCj4gU2VudDog
VHVlc2RheSwgSnVseSAwNywgMjAxNSA4OjU0IEFNDQo+IFRvOiBEYXZpZCBTLiBNaWxsZXI7IG5l
dGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gQ2M6IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wu
b3JnOyBLaXJzaGVyLCBKZWZmcmV5IFQ7IEZ1amluYWthLCBUb2RkDQo+IFN1YmplY3Q6IFtQQVRD
SCAyLzNdIG1pc3NpbmcgcnRubF91bmxvY2sgaW4gaWdiX3NyaW92X3JlaW5pdCgpDQo+IA0KPiBT
aWduZWQtb2ZmLWJ5OiBWYXNpbHkgQXZlcmluIDx2dnNAdmlydHVvenpvLmNvbT4NCj4gLS0tDQo+
ICBkcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pZ2IvaWdiX21haW4uYyB8IDEgKw0KPiAgMSBm
aWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspDQoNClRlc3RlZC1ieTogQWFyb24gQnJvd24gPGFh
cm9uLmYuYnJvd25AaW50ZWwuY29tPg0K
