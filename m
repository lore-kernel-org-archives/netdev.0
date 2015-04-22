From: MITSUHIRO KIMURA <mitsuhiro.kimura.kc@renesas.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Wed, 22 Apr 2015 05:04:13 +0000
Message-ID: <SIXPR06MB03142A49C392C39922DC2BDA3EE0@SIXPR06MB031.apcprd06.prod.outlook.com>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
 <552C4554.2070608@gmail.com> <552D8898.3060905@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	MASARU NAGAI <masaru.nagai.vx@renesas.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:37652 "EHLO
	relmlie3.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752278AbbDVFEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 01:04:20 -0400
In-Reply-To: <552D8898.3060905@cogentembedded.com>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGVsbG8gU2VyZ2VpLg0KDQogKDIwMTUvMDQvMTUgNjozNzoyOCksIFNlcmdlaSBTaHR5bHlvdiB3
cm90ZToNCj4gPj4gKwkJaWYgKCFyYXZiX3R4X2ZyZWUobmRldiwgcSkpIHsNCj4gPj4gKwkJCW5l
dGlmX3dhcm4ocHJpdiwgdHhfcXVldWVkLCBuZGV2LCAiVFggRkQgZXhoYXVzdGVkLlxuIik7DQo+
ID4+ICsJCQluZXRpZl9zdG9wX3F1ZXVlKG5kZXYpOw0KPiA+PiArCQkJc3Bpbl91bmxvY2tfaXJx
cmVzdG9yZSgmcHJpdi0+bG9jaywgZmxhZ3MpOw0KPiA+PiArCQkJcmV0dXJuIE5FVERFVl9UWF9C
VVNZOw0KPiA+PiArCQl9DQo+ID4+ICsJfQ0KPiA+PiArCWVudHJ5ID0gcHJpdi0+Y3VyX3R4W3Fd
ICUgcHJpdi0+bnVtX3R4X3JpbmdbcV07DQo+ID4+ICsJcHJpdi0+Y3VyX3R4W3FdKys7DQo+ID4+
ICsJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmcHJpdi0+bG9jaywgZmxhZ3MpOw0KPiA+PiArDQo+
ID4+ICsJaWYgKHNrYl9wdXRfcGFkdG8oc2tiLCBFVEhfWkxFTikpDQo+ID4+ICsJCXJldHVybiBO
RVRERVZfVFhfT0s7DQo+ID4+ICsNCj4gPj4gKwlwcml2LT50eF9za2JbcV1bZW50cnldID0gc2ti
Ow0KPiA+PiArCWJ1ZmZlciA9IFBUUl9BTElHTihwcml2LT50eF9idWZmZXJzW3FdW2VudHJ5XSwg
UkFWQl9BTElHTik7DQo+ID4+ICsJbWVtY3B5KGJ1ZmZlciwgc2tiLT5kYXRhLCBza2ItPmxlbik7
DQo+IA0KPiA+IH4xNTAwIGJ5dGVzIG1lbWNweSgpLCBub3QgZ29vZC4uLg0KPiANCj4gICAgIEkn
bSBsb29raW5nIGluIHRoZSBtYW51YWwgYW5kIG5vdCBmaW5kaW5nIHRoZSBoYXJkIHJlcXVpcmVt
ZW50IHRvIGhhdmUgdGhlDQo+IGJ1ZmZlciBhZGRyZXNzIGFsaWduZWQgdG8gMTI4IGJ5dGVzIChS
QVZCX0FMSUdOKSwgc2lnaC4uLiBLaW11cmEtc2FuPw0KDQpUaGVyZSBhcmUgdGhlIGhhcmR3YXJl
IHJlcXVpcmVtZW50IHRoYXQgdGhlIGZyYW1lIGRhdGEgbXVzdCBiZSBhbGlnbmVkIHdpdGgNCmEg
MzItYml0IGJvdW5kYXJ5IGluIHRoZSBVUkFNLCBzZWUgc2VjdGlvbiA0NUEuMy4zLjEgRGF0YSBS
ZXByZXNlbnRhdGlvbg0KaW4gdGhlIG1hbnVhbC4NCkkgdGhpbmsgdGhhdCB0aGUgb3JpZ2luYWwg
c2tiLT5kYXRhIGlzIGFsbW9zdCBhbGlnbmVkIHdpdGggMiBieXRlcyBib3VuZGFyeQ0KYnkgTkVU
X0lQX0FMSU5HLCBzbyB3ZSBjb3BpZWQgb3JpZ2luYWwgc2tiLT5kYXRhIHRvIHRoZSBsb2NhbCBh
bGlnbmVkIGJ1ZmZlci4NCg0KSW4gYWRkaXRpb24sIHNlZSBzZWN0aW9uIDQ1QS4zLjMuMTIgVGlw
cyBmb3IgT3B0aW1pemluZyBQZXJmb3JtYW5jZSBpbiBIYW5kbGluZw0KRGVzY3JpcHRvcnMsIGl0
IG1lbnRpb25lZCB0aGF0IGZyYW1lIGRhdGEgaXMgYWNjZXNzZWQgaW4gYmxvY2tzIHVwIHRvIDEy
OCBieXRlcw0KYW5kIHRoZSBudW1iZXIgb2YgMTI4IGJ5dGUgYm9yZGVycyAoYWRkcmVzc2VzIEgn
eHh4MDAgYW5kIEgneHh4ODApIGFuZCBmcmFtZSBkYXRhDQppbnNpZGUgc2hvdWxkIGJlIG1pbmlt
aXplZC4NClNvIHdlIHNldCBSQVZCX0FMSUdOIHRvIDEyOCBieXRlcy4NCg0KQmVzdCBSZWdhcmRz
LA0KTWl0c3VoaXJvIEtpbXVyYQ0KDQo=
