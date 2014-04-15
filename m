From: "Li, Zhen-Hua" <zhen-hual@hp.com>
Subject: Re: [PATCH 1/1] driver/net: add missing rtnl lock/unlock for benet
Date: Tue, 15 Apr 2014 12:59:56 +0000
Message-ID: <1249C41B-D72F-40C8-A8F1-D135D02A1511@hp.com>
References: <1397544352-28841-1-git-send-email-zhen-hual@hp.com>
 <b4855c2a-5a63-47a5-ba61-f9ce736f6401@CMEXHTCAS1.ad.emulex.com>
 <534CF596.3010609@hp.com>,<069bdb52-6176-407a-b7fc-3f23a944a529@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sathya Perla <Sathya.Perla@Emulex.Com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <069bdb52-6176-407a-b7fc-3f23a944a529@CMEXHTCAS2.ad.emulex.com>
Content-Language: zh-CN
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WWVzLCB0aGF0J3Mgb2sgZm9yIG1lLg0KDQq3otfUztK1xCBpUGhvbmUNCg0K1NogMjAxNMTqNNTC
MTXI1aOsz8LO5zc6NTejrCJTYXRoeWEgUGVybGEiIDxTYXRoeWEuUGVybGFARW11bGV4LkNvbT4g
0LS1wKO6DQoNCj4+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+PiBGcm9tOiBMaSwgWmhl
bkh1YSBbbWFpbHRvOnpoZW4taHVhbEBocC5jb21dDQo+PiANCj4+IEJlY2F1c2UgbmV0aWZfcnVu
bmluZygpIGlzIGNhbGxlZCBpbiBuZXRpZl9kZXZpY2VfZGV0YWNoIGFuZA0KPj4gbmV0aWZfZGV2
aWNlX2F0dGFjaC4gVG8gYXZvaWQgZGV2IHN0YXR1cyBjaGFuZ2VkIHdoaWxlDQo+PiBuZXRpZl9k
ZXZpY2VfZGV0YWNoL2F0dGFjaCBpcyBub3QgZmluaXNoZWQsIEkgdGhpbmsgYSBydG5sX2xvY2sg
YW5kDQo+PiB1bmxvY2sgc2hvdWxkIGJlIGNhbGxlZCB0byBhdm9pZCB0aGlzLg0KPiANCj4gT2su
IEknZCBsaWtlIHRvIHRoZW4gZmFjdG9yIHRoZSBjb2RlIHNsaWdodGx5IGRpZmZlcmVudGx5IGJ5
IHVzaW5nDQo+IHJvdXRpbmVzIGxpa2UgdGhpczoNCj4gDQo+IGJlX2Nsb3NlX3N5bmMoKSB7DQo+
ICAgIHJ0bmxfbG9jaygpOw0KPiANCj4gICAgICBuZXRpZl9kZXZpY2VfZGV0YWNoKG5ldGRldik7
DQo+ICAgICAgIGlmIChuZXRpZl9ydW5uaW5nKG5ldGRldikpDQo+ICAgICAgICAgICBiZV9jbG9z
ZShuZXRkZXYpOw0KPiANCj4gICAgcnRubF91bmxvY2soKTsNCj4gfQ0KPiANCj4gYW5kIHNpbWls
YXJseSBmb3IgYmVfb3Blbl9zeW5jKCkNCj4gDQo+IEFuZCwgSSdkIG5lZWQgc29tZSB0aW1lIHRv
IHRlc3QgdGhlc2UgZmxvd3MgdG9vLg0KPiBXb3VsZCB5b3UgYmUgT0sgd2l0aCB0aGlzPw0KPiAN
Cj4gdGhhbmtzLA0KPiAtU2F0aHlhDQo=
