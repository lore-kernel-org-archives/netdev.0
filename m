From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Thu, 26 Jun 2014 14:55:11 +0000
Message-ID: <072cf0ff85474ca8af2c3930f822ecad@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
 <20140620045704.GA4850@aepfle.de> <20140620051213.GA9960@kroah.com>
 <ff458d1b896d4a70a32fa7709911274c@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623080242.GA16924@aepfle.de>
 <06b508cbb6b949f4b3e13e7797948e56@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623131723.GA7026@aepfle.de>
 <5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623162705.GA5957@aepfle.de>
 <4ee8be5360a44b5abfa6df871ec45527@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140626084539.GA32471@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Greg KH <greg@kroah.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140626084539.GA32471@aepfle.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogT2xhZiBIZXJpbmcgW21h
aWx0bzpvbGFmQGFlcGZsZS5kZV0NCj4gU2VudDogVGh1cnNkYXksIEp1bmUgMjYsIDIwMTQgNDo0
NiBBTQ0KPiBUbzogSGFpeWFuZyBaaGFuZw0KPiBDYzogR3JlZyBLSDsgbmV0ZGV2QHZnZXIua2Vy
bmVsLm9yZzsgamFzb3dhbmdAcmVkaGF0LmNvbTsgZHJpdmVyZGV2LQ0KPiBkZXZlbEBsaW51eGRy
aXZlcnByb2plY3Qub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOw0KPiBkYXZlbUBk
YXZlbWxvZnQubmV0DQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5leHRdIGh5cGVydjogQWRk
IGhhbmRsZXIgZm9yDQo+IFJORElTX1NUQVRVU19ORVRXT1JLX0NIQU5HRSBldmVudA0KPiANCj4g
T24gTW9uLCBKdW4gMjMsIEhhaXlhbmcgWmhhbmcgd3JvdGU6DQo+IA0KPiA+IFllcywgdGhlcmUg
aXMgYSBsaW5rIGRvd24vdXAgZXZlbnQgZnJvbSB0aGUgaG9zdCwgd2UgY3VycmVudGx5IGNhbGwN
Cj4gPiBuZXRpZl9jYXJyaWVyX29mZigpIC8gbmV0aWZfY2Fycmllcl9vbigpIHdpdGggdGhlc2Ug
ZXZlbnRzLiBXaWxsDQo+ID4gaG90cGx1ZyBzY3JpcHRzIGJlIHRyaWdnZXJlZCBieSBuZXRpZl9j
YXJyaWVyX29mZi9vbj8gV2hlcmUgYXJlIHRoZSBzY3JpcHRzDQo+IGxvY2F0ZWQgYXQgKFNMRVMp
Pw0KPiANCj4gSW4gL2V0Yy9zeXNjb25maWcvbmV0d29yay9pZmNmZy1ldGgwIFNUQVJUTU9ERT0g
c2hvdWxkIGJlIHNldCB0byAiaWZwbHVnZCIsDQo+IHRoaXMgd2lsbCBtb3N0IGxpa2VseSBmaXgg
dGhpcyBzb3J0IG9mIHNldHVwLg0KDQpUaGFua3MgZm9yIHRoZSBpbmZvISBJJ2xsIGxldCBvdXIg
dGVhbSBrbm93Lg0KDQotIEhhaXlhbmcNCg==
