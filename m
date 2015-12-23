From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Wed, 23 Dec 2015 11:15:16 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F9964B@RTITEXDAG01.realtek.com.tw>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
	 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
	 <20151208143305.GB18728@al>
	 <0835B3720019904CB8F7AA43166CEEB2F94D11@RTITMBSV03.realtek.com.tw>
	 <1450782082.8824.23.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F94FFF@RTITMBSV03.realtek.com.tw>
	 <1450858813.6437.2.camel@suse.de>
	 <0835B3720019904CB8F7AA43166CEEB2F9547E@RTITMBSV03.realtek.com.tw>
 <1450867558.6437.10.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"peter@lekensteyn.nl" <peter@lekensteyn.nl>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450867558.6437.10.camel@suse.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T2xpdmVyIE5ldWt1bSBbbWFpbHRvOm9uZXVrdW1Ac3VzZS5jb21dDQo+IFNlbnQ6IFdlZG5lc2Rh
eSwgRGVjZW1iZXIgMjMsIDIwMTUgNjo0NiBQTQ0KWy4uLl0NCj4gVGhhdCBpcyBpbmRlZWQgYSBw
cm9ibGVtIGFuZCBJIG5lZWQgdG8gdGhpbmsgYSBiaXQgYWJvdXQgZmluZGluZw0KPiBhIGdvb2Qg
c29sdXRpb24uIElmIHlvdSBhcmUgaGFwcHkgd2l0aCBhbiBpbmVsZWdhbnQgc29sdXRpb24sIHlv
dSBjYW4NCj4gdXNlIGEgcG1fbm90aWZpZXIsIHdoaWNoIHdpbGwgdGVsbCB5b3UgdGhhdCB0aGUg
c3lzdGVtIGlzIGdvaW5nDQo+IHRvIHN1c3BlbmQuIFRoaXMgaXMgZG9jdW1lbnRlZDoNCj4gDQo+
IGh0dHBzOi8vd3d3Lmtlcm5lbC5vcmcvZG9jL0RvY3VtZW50YXRpb24vcG93ZXIvbm90aWZpZXJz
LnR4dA0KDQpUaGFua3MuIEkgd291bGQgc3R1ZHkgaXQgYWZ0ZXIgZml4aW5nIHRoZSByZXNldF9y
ZXN1bWUoKSBpc3N1ZS4NCg0KQmVzdCBSZWdhcmRzLA0KSGF5ZXMNCg0K
