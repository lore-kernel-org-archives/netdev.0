From: Patrick Ruddy <pruddy@Brocade.com>
Subject: Re: [PATCH] Netlink messages for multicast HW addr programming
Date: Fri, 22 Jan 2016 15:49:36 +0000
Message-ID: <1453477775.20378.15.camel@brocade.com>
References: <1453376874-17389-1-git-send-email-pruddy@brocade.com>
	 <20160121200419.GB2251@nanopsycho.orion>
	 <1453474315.20378.7.camel@brocade.com>
	 <20160122150508.GD2211@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Stapleton <dstaplet@Brocade.com>,
	Olufemi Komolafe <okomolaf@Brocade.com>,
	"Stephen Hemminger" <shemming@Brocade.com>
To: "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:42716 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751033AbcAVPts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 10:49:48 -0500
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u0MFTAAM025631
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 07:49:47 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 20gpc8dha9-5
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 07:49:47 -0800
In-Reply-To: <20160122150508.GD2211@nanopsycho.orion>
Content-Language: en-US
Content-ID: <6D5856AECE384F4691441881EEF23E1A@brocade.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCAyMDE2LTAxLTIyIGF0IDE2OjA1ICswMTAwLCBKaXJpIFBpcmtvIHdyb3RlOg0KPiBG
cmksIEphbiAyMiwgMjAxNiBhdCAwMzo1MTo1NVBNIENFVCwgcHJ1ZGR5QEJyb2NhZGUuY29tIHdy
b3RlOg0KPiA+T24gVGh1LCAyMDE2LTAxLTIxIGF0IDIxOjA0ICswMTAwLCBKaXJpIFBpcmtvIHdy
b3RlOg0KPiA+PiBUaHUsIEphbiAyMSwgMjAxNiBhdCAxMjo0Nzo1NFBNIENFVCwgcHJ1ZGR5QGJy
b2NhZGUuY29tIHdyb3RlOg0KPiA+PiA+QWRkIFJUTV9ORVdBRERSIGFuZCBSVE1fREVMQUREUiBu
ZXRsaW5rIG1lc3NhZ2VzIHRvIGluZGljYXRlDQo+ID4+ID5pbnRlcmVzdCBpbiBzcGVjaWZpYyBt
dWx0aWNhc3QgaGFyZHdhcmUgYWRkcmVzc2VzLiBUaGVzZSBtZXNzYWdlcw0KPiA+PiA+YXJlIHNl
bnQgd2hlbiBhZGRyZXNzZWQgYXJlIGFkZGVkIG9yIGRlbGV0ZWQgZnJvbSB0aGUgYXBwcm9wcmlh
dGUNCj4gPj4gPmludGVyZmFjZSBkcml2ZXIuDQo+ID4+ID4NCj4gPj4gPlNpZ25lZC1vZmYtYnk6
IFBhdHJpY2sgUnVkZHkgPHBydWRkeUBicm9jYWRlLmNvbT4NCj4gPj4gPg0KPiA+PiA+ZGlmZiAt
LWdpdCBhL25ldC9jb3JlL2Rldl9hZGRyX2xpc3RzLmMgYi9uZXQvY29yZS9kZXZfYWRkcl9saXN0
cy5jDQo+ID4+ID5pbmRleCBjMDU0OGQyLi5hMGViYWRkIDEwMDY0NA0KPiA+PiA+LS0tIGEvbmV0
L2NvcmUvZGV2X2FkZHJfbGlzdHMuYw0KPiA+PiA+KysrIGIvbmV0L2NvcmUvZGV2X2FkZHJfbGlz
dHMuYw0KPiA+PiA+QEAgLTEyLDYgKzEyLDcgQEANCj4gPj4gPiAgKi8NCj4gPj4gPiANCj4gPj4g
PiAjaW5jbHVkZSA8bGludXgvbmV0ZGV2aWNlLmg+DQo+ID4+ID4rI2luY2x1ZGUgPG5ldC9uZXRs
aW5rLmg+DQo+ID4+ID4gI2luY2x1ZGUgPGxpbnV4L3J0bmV0bGluay5oPg0KPiA+PiA+ICNpbmNs
dWRlIDxsaW51eC9leHBvcnQuaD4NCj4gPj4gPiAjaW5jbHVkZSA8bGludXgvbGlzdC5oPg0KPiA+
PiA+QEAgLTY2MSw2ICs2NjIsNjIgQEAgb3V0Og0KPiA+PiA+IH0NCj4gPj4gPiBFWFBPUlRfU1lN
Qk9MKGRldl9tY19hZGRfZXhjbCk7DQo+ID4+ID4gDQo+ID4+ID4rc3RhdGljIGludCBmaWxsX2Fk
ZHIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5ldF9kZXZpY2UgKmRldiwNCj4gPj4gPisJ
CSAgICAgY29uc3QgdW5zaWduZWQgY2hhciAqYWRkciwgaW50IHR5cGUpDQo+ID4+ID4rew0KPiA+
PiA+KwlzdHJ1Y3Qgbmxtc2doZHIgKm5saDsNCj4gPj4gPisJc3RydWN0IGlmYWRkcm1zZyAqaWZt
Ow0KPiA+PiA+Kw0KPiA+PiA+KwlubGggPSBubG1zZ19wdXQoc2tiLCAwLCAwLCB0eXBlLCBzaXpl
b2YoKmlmbSksIDApOw0KPiA+PiA+KwlpZiAobmxoID09IE5VTEwpDQo+ID4+ID4rCQlyZXR1cm4g
LUVNU0dTSVpFOw0KPiA+PiA+Kw0KPiA+PiA+KwlpZm0gPSBubG1zZ19kYXRhKG5saCk7DQo+ID4+
ID4rCWlmbS0+aWZhX2ZhbWlseSA9IEFGX1VOU1BFQzsNCj4gPj4gPisJaWZtLT5pZmFfcHJlZml4
bGVuID0gMDsNCj4gPj4gPisJaWZtLT5pZmFfZmxhZ3MgPSBJRkFfRl9QRVJNQU5FTlQ7DQo+ID4+
ID4rCWlmbS0+aWZhX3Njb3BlID0gUlRfU0NPUEVfTElOSzsNCj4gPj4gPisJaWZtLT5pZmFfaW5k
ZXggPSBkZXYtPmlmaW5kZXg7DQo+ID4+ID4rCWlmIChubGFfcHV0KHNrYiwgSUZBX0FERFJFU1Ms
IGRldi0+YWRkcl9sZW4sIGFkZHIpKQ0KPiA+PiA+KwkJZ290byBubGFfcHV0X2ZhaWx1cmU7DQo+
ID4+ID4rCW5sbXNnX2VuZChza2IsIG5saCk7DQo+ID4+IA0KPiA+PiBIb3cgY2FuIHVzZXJzcGFj
ZSB0ZWxsIGlmIHRoaXMgaXMgYSBtdWx0aWNhc3QgYWRkcj8gQWxzbywgd2h5IG5vdCBhZGQNCj4g
Pj4gbm90aWZpY2F0aW9ucyBmb3IgdW5pY2FzdCBhZGRycyBzbyB3ZSBoYW5kbGUgYm90aCB0aGUg
c2FtZT8NCj4gPg0KPiA+SSBhbSBvbmx5IHVzaW5nIHRoaXMgUlRNX05FVy9ERUxBRERSIEFGX1VO
U1BFQyBtZXNzYWdlIGZvciBtdWx0aWNhc3QNCj4gPmFkZHJlc3Nlcy4gSSB1bmRlcnN0YW5kIHRo
YXQgdGhlIHVuaWNhc3QgYWRkcmVzc2VzIGFyZSBub3RpZmllZCBpbiB0aGUNCj4gPlJUTV9ORVcv
REVMTElOSy4NCj4gDQo+IGRldi0+ZGV2X2FkZHIgaXMgbm90aWZpZWQgYnkgdGhhdC4gVUMgYWRk
cmVzc2VzIGRvIG5vdCBoYXZlIGFueQ0KPiBub3RpZmljYXRpb24gbm93Lg0KSXQgaXMgdGhlIG11
bHRpY2FzdCBNQUMgYWRkcmVzcyAoaWUgdGhlIG11bHRpY2FzdCBlcXVpdmFsZW50IG9mIHRoZQ0K
ZGV2X2FkZHIpIHRoYXQgd2UgYXJlIG5vdGlmeWluZyBoZXJlIHJpZ2h0PyBOb3QgTDMgYWRkcmVz
c2VzLg0KDQotcHINCg0K
