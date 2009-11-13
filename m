From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Fri, 13 Nov 2009 14:09:03 -0800 (PST)
Message-ID: <20091113.140903.222779377.davem@davemloft.net>
References: <4AF8C4E9.3030907@gmail.com>
	<4AF8E165.6000801@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=gb2312
Content-Transfer-Encoding: base64
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35430
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755320AbZKMWIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 17:08:48 -0500
In-Reply-To: <4AF8E165.6000801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogVHVlLCAx
MCBOb3YgMjAwOSAwNDo0MzozMyArMDEwMA0KDQo+IENoYW5nbGkgR2FvIGEgqKZjcml0IDoNCj4+
IGNoZWNrIHRoZSByZXR1cm4gdmFsdWUgb2YgbmRvX3NlbGVjdF9xdWV1ZSgpDQo+PiANCj4+IENo
ZWNrIHRoZSByZXR1cm4gdmFsdWUgb2YgbmRvX3NlbGVjdF9xdWV1ZSgpLiBJZiB0aGUgdmFsdWUg
aXNuJ3Qgc21hbGxlcg0KPj4gdGhhbiB0aGUgcmVhbF9udW1fdHhfcXVldWVzLCBwcmludCBhIHdh
cm5pbmcgbWVzc2FnZSwgYW5kIHJlc2V0IGl0IHRvIHplcm8uDQo+PiANCj4+IFNpZ25lZC1vZmYt
Ynk6IENoYW5nbGkgR2FvIDx4aWFvc3VvQGdtYWlsLmNvbT4NCj4gDQo+IEFja2VkLWJ5OiBFcmlj
IER1bWF6ZXQgPGVyaWMuZHVtYXpldEBnbWFpbC5jb20+DQoNClRoaXMgcGF0Y2ggZG9lcyBub3Qg
YXBwbHkgcHJvcGVybHkgdG8gbmV0LW5leHQtMi42LCB0aGUgZGV2X3BpY2tfdHgoKQ0KZnVuY3Rp
b24gbG9va3MgYSBsb3QgZGlmZmVyZW50IG5vdy4NCg0KUGxlYXNlIHJlc3BpbiB0aGlzIHBhdGNo
IGFuZCByZXN1Ym1pdCwgdGhhbmsgeW91Lg0K
