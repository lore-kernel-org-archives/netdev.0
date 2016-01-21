From: Maninder Singh <maninder1.s@samsung.com>
Subject: Re: [PATCH] af_packet: Raw socket destruction warning fix
Date: Thu, 21 Jan 2016 11:40:14 +0000 (GMT)
Message-ID: <2036003091.741801453376409338.JavaMail.weblogic@ep2mlwas01a>
Reply-To: maninder1.s@samsung.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"willemb@google.com" <willemb@google.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"eyal.birger@gmail.com" <eyal.birger@gmail.com>,
	"tklauser@distanz.ch" <tklauser@distanz.ch>,
	"fruggeri@aristanetworks.com" <fruggeri@aristanetworks.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	PANKAJ MISHRA <pankaj.m@samsung.com>,
	Geon-ho Kim <gh007.kim@samsung.com>,
	Hak-Bong Lee <hakbong5.lee@samsung.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Vaneet Narang <v.narang@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
MIME-version: 1.0
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgRGFuaWVsLA0KDQo+VGhlIG90aGVyIHNvY2tfcHV0KCkgaW4gcGFja2V0X3JlbGVhc2UoKSB0
byBkcm9wIHRoZSBmaW5hbCByZWYgYW5kIGNhbGwgaW50bw0KPnNrX2ZyZWUoKSwgd2hpY2ggZHJv
cHMgdGhlIDEgcmVmIG9uIHRoZSBza193bWVtX2FsbG9jIGZyb20gaW5pdCB0aW1lLiBTaW5jZSB5
b3UNCj5nb3QgaW50byBfX3NrX2ZyZWUoKSB2aWEgc29ja193ZnJlZSgpIGRlc3RydWN0b3IsIHlv
dXIgc29ja2V0IG11c3QgaGF2ZSBpbnZva2VkDQo+cGFja2V0X3JlbGVhc2UoKSBwcmlvciB0byB0
aGlzIChwZXJoYXBzIGtlcm5lbCBkZXN0cm95aW5nIHRoZSBwcm9jZXNzKS4NCj4NCj5XaGF0IGtl
cm5lbCBkbyB5b3UgdXNlPw0KDQpJc3N1ZSBpcyBjb21pbmcgZm9yIDMuMTAuNTguDQoNCj4+IERy
aXZlciBjYWxscyBkZXZfa2ZyZWVfc2tiX2FueS0+ZGV2X2tmcmVlX3NrYl9pcnENCj4+IGFuZCBp
dCBhZGRzIGJ1ZmZlciBpbiBjb21wbGV0aW9uIHF1ZXVlIHRvIGZyZWUgYW5kIHJhaXNlcyBzb2Z0
aXJxIE5FVF9UWF9TT0ZUSVJRDQo+Pg0KPj4gbmV0X3R4X2FjdGlvbi0+X19rZnJlZV9za2ItPnNr
Yl9yZWxlYXNlX2FsbC0+c2tiX3JlbGVhc2VfaGVhZF9zdGF0ZS0+c29ja193ZnJlZS0+DQo+PiBf
X3NrX2ZyZWUtPnBhY2tldF9zb2NrX2Rlc3RydWN0DQo+Pg0KPj4gQWxzbyBwdXJnaW5nIG9mIHJl
Y2VpdmUgcXVldWUgaGFzIGJlZW4gdGFrZW4gY2FyZSBpbiBvdGhlciBwcm90b2NvbHMu
