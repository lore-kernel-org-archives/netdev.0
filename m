From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 10:09:28 +0000
Message-ID: <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
 <20170420015750.6828-5-jeffrey.t.kirsher@intel.com>
 <CAJ3xEMiCuV5A_Ccy7=mKSjc9xxhg4enUxDq-MM-cO3YjSa439A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0071.outbound.protection.outlook.com ([104.47.41.71]:48544
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1030708AbdDTKJb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 06:09:31 -0400
In-Reply-To: <CAJ3xEMiCuV5A_Ccy7=mKSjc9xxhg4enUxDq-MM-cO3YjSa439A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IER1bXAgc29tZSBpbnRlcm5hbCBzdGF0ZSBhYm91dCBWRnMgdGhyb3VnaCBkZWJ1Z2ZzLiBU
aGlzIHByb3ZpZGVzDQo+ID4gaW5mb3JtYXRpb24gbm90IGF2YWlsYWJsZSB3aXRoICdpcCBsaW5r
IHNob3cnLg0KPiANCj4gc3VjaCBhcz8NCj4gDQo+IGRvbm53YW50b2JldGhlZGVidWdmc3BvbGlj
ZSwgYnV0IHN0aWxsLCBpbiB0aGUgMi0zIHRpbWVzIHdlIHRyaWVkIHRvIHB1c2gNCj4gZGVidWdm
cyB0byBNTE5YIE5JQyBkcml2ZXJzLCBEYXZlIGRpc2FsbG93ZWQgdGhhdCwgYW5kIGxhdGVseSB0
aGUgc3dpdGNoDQo+IHRlYW0gZXZlbiB3ZW50IGZ1cnRoZXIgYW5kIGRlbGV0ZWQgdGhhdCBwb3J0
aW9uIG9mIHRoZSBtbHhzdyBkcml2ZXIgLS0gYWxsIHRvDQo+IGFsbCwgIEkgZG9uJ3Qgc2VlIG11
Y2ggcG9pbnQgZm9yIHRoZXNlIHR5cGUgb2YgY2hhbmdlcywgdGhvdWdodHM/DQoNCkRvbid0IHdh
bnQgdG8gaGlramFjayB5b3VyIHRocmVhZCwgYnV0IGNvbnRpbnVpbmcgdGhpcyB0b3BpYyAtDQpJ
cyB0aGVyZSBzb21lIGZsYXQtb3V0IGRpc2FwcHJvdmFsIGZvciBkZWJ1Z2ZzIGluIG5ldC1uZXh0
IG5vdz8NCg0KV2UncmUgY3VycmVudGx5IGludGVybmFsbHkgZW5nYWdlZCB3aXRoIGFkZGluZyBx
ZWQgc3VwcG9ydCBmb3IgcmVnaXN0ZXIgZHVtcHMNClt+ZXF1aXZhbGVudHMgZm9yIGBldGh0b29s
IC1kJyBvdXRwdXRzXSB0aHJvdWdoIGRlYnVnZnMsIG9uIGJlaGFsZiBvZiBzdG9yYWdlDQpkcml2
ZXJzIFtxZWRpL3FlZGZdIGxhY2tpbmcgdGhlIEFQSSBmb3IgZG9pbmcgdGhhdC4NCg0K
