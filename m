From: "Coelho, Luciano" <luciano.coelho@intel.com>
Subject: Re: [GIT] Networking
Date: Thu, 7 Sep 2017 04:11:36 +0000
Message-ID: <1504757495.5400.89.camel@intel.com>
References: <20170905.214143.826912481689443792.davem@davemloft.net>
         <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linuxwifi <linuxwifi@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "Berg, Johannes" <johannes.berg@intel.com>,
        "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com>
Content-Language: en-US
Content-ID: <D107796AD8A08B4B9F4D134EDA1582D0@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gV2VkLCAyMDE3LTA5LTA2IGF0IDE2OjI3IC0wNzAwLCBMaW51cyBUb3J2YWxkcyB3cm90ZToN
Cj4gVGhpcyBwdWxsIHJlcXVlc3QgY29tcGxldGVseSBicmVha3MgSW50ZWwgd2lyZWxlc3MgZm9y
IG1lLg0KPiANCj4gVGhpcyBpcyBteSB0cnVzdHkgb2xkIFhQUyAxMyAoOTM1MCksIHVzaW5nIElu
dGVsIFdpcmVsZXNzIDgyNjAgKHJldiAzYSkuDQo+IA0KPiBUaGF0IHJlbWFpbnMgYSB2ZXJ5IHN0
YW5kYXJkIEludGVsIG1hY2hpbmUgd2l0aCBhYnNvbHV0ZWx5IHplcm8gb2RkDQo+IHRoaW5ncyBn
b2luZyBvbi4NCj4gDQo+IFRoZSBmaXJtd2FyZSBpcyBpd2x3aWZpLTgwMDBDLTI4LnVjb2RlIGZy
b20NCj4gaXdsNzI2MC1maXJtd2FyZS0yNS4zMC4xMy4wLTc1LmZjMjYubm9hcmNoLCBhbmQgdGhl
IGtlcm5lbCByZXBvcnRzDQo+IA0KPiAgIGl3bHdpZmkgMDAwMDozYTowMC4wOiBsb2FkZWQgZmly
bXdhcmUgdmVyc2lvbiAyNy40NTU0NzAuMCBvcF9tb2RlIGl3bG12bQ0KPiANCj4gdGhlIHRoaW5n
IHN0YXJ0cyBhY3RpbmcgYmFkbHkgd2l0aCB0aGlzOg0KPiANCj4gICBpd2x3aWZpIDAwMDA6M2E6
MDAuMDogRlcgRXJyb3Igbm90aWZpY2F0aW9uOiB0eXBlIDB4MDAwMDAwMDAgY21kX2lkIDB4MDQN
Cj4gICBpd2x3aWZpIDAwMDA6M2E6MDAuMDogRlcgRXJyb3Igbm90aWZpY2F0aW9uOiBzZXEgMHgw
MDAwIHNlcnZpY2UgMHgwMDAwMDAwNA0KPiAgIGl3bHdpZmkgMDAwMDozYTowMC4wOiBGVyBFcnJv
ciBub3RpZmljYXRpb246IHRpbWVzdGFtcCAweCAgICAgICAgICAgIDVEODQNCj4gICBpd2x3aWZp
IDAwMDA6M2E6MDAuMDogTWljcm9jb2RlIFNXIGVycm9yIGRldGVjdGVkLiAgUmVzdGFydGluZyAw
eDIwMDAwMDAuDQo+ICAgaXdsd2lmaSAwMDAwOjNhOjAwLjA6IFN0YXJ0IElXTCBFcnJvciBMb2cg
RHVtcDoNCj4gICBpd2x3aWZpIDAwMDA6M2E6MDAuMDogU3RhdHVzOiAweDAwMDAwMTAwLCBjb3Vu
dDogNg0KPiAgIGl3bHdpZmkgMDAwMDozYTowMC4wOiBMb2FkZWQgZmlybXdhcmUgdmVyc2lvbjog
MjcuNDU1NDcwLjANCj4gICBpd2x3aWZpIDAwMDA6M2E6MDAuMDogMHgwMDAwMDAzOCB8IEJBRF9D
T01NQU5EDQo+ICAgaXdsd2lmaSAwMDAwOjNhOjAwLjA6IDB4MDBBMDAyRjAgfCB0cm1faHdfc3Rh
dHVzMA0KPiAgIC4uLg0KPiAgIGl3bHdpZmkgMDAwMDozYTowMC4wOiAweDAwMDAwMDAwIHwgaXNy
IHN0YXR1cyByZWcNCj4gICBpZWVlODAyMTEgcGh5MDogSGFyZHdhcmUgcmVzdGFydCB3YXMgcmVx
dWVzdGVkDQo+ICAgaXdsd2lmaSAwMDAwOjNhOjAwLjA6IEZXIGVycm9yIGluIFNZTkMgQ01EIE1B
Q19DT05URVhUX0NNRA0KDQpUaGlzIHNlZW1zIHRvIGJlIGEgcHJvYmxlbSB3aXRoIGJhY2t3YXJk
cy1jb21wYXRpYmlsaXR5IHdpdGggRlcgdmVyc2lvbg0KMjcuICBXZSBhcmUgbm93IGluIHZlcnNp
b24gMzFbMV0gYW5kIHVwZ3JhZGluZyB3aWxsIHByb2JhYmx5IGZpeCB0aGF0Lg0KDQpCdXQgb2J2
aW91c2x5IHRoZSBkcml2ZXIgc2hvdWxkIG5vdCBmYWlsIG1pc2VyYWJseSBsaWtlIHRoaXMgd2l0
aA0KdmVyc2lvbiAyNywgYmVjYXVzZSBpdCBjbGFpbXMgdG8gc3VwcG9ydCBpdCBzdGlsbC4NCg0K
SSdtIGxvb2tpbmcgaW50byB0aGlzIG5vdyBhbmQgd2lsbCBwcm92aWRlIGEgZml4IGFzYXAuDQoN
ClsxXSBodHRwczovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9maXJt
d2FyZS9saW51eC1maXJtd2FyZS5naXQvdHJlZS9pd2x3aWZpLTgwMDBDLTMxLnVjb2RlDQoNCg0K
LS0NCkNoZWVycywNCkx1Y2Eu
