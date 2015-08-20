From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: Add values missing in @get_stats64 from HW counters
Date: Thu, 20 Aug 2015 02:43:14 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F4C1FA@RTITMBSV03.realtek.com.tw>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <20150818214017.GA14914@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2F4B846@RTITMBSV03.realtek.com.tw>
 <20150819091318.GV17917@calimero.vinschen.de>
 <0835B3720019904CB8F7AA43166CEEB2F4BF49@RTITMBSV03.realtek.com.tw>
 <20150819130744.GA24832@calimero.vinschen.de>
 <20150819142416.GA26271@calimero.vinschen.de>
 <20150819192414.GC30904@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	nic_swsd <nic_swsd@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>
To: Corinna Vinschen <vinschen@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:45812 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbbHTCne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 22:43:34 -0400
In-Reply-To: <20150819192414.GC30904@calimero.vinschen.de>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Q29yaW5uYSBWaW5zY2hlbiBbbWFpbHRvOnZpbnNjaGVuQHJlZGhhdC5jb21dDQo+IFNlbnQ6IFRo
dXJzZGF5LCBBdWd1c3QgMjAsIDIwMTUgMzoyNCBBTQ0KWy4uLl0NCj4gKwkvKg0KPiArCSAqIFZl
cnNpb25zIHByaW9yIHRvIFJUTF9HSUdBX01BQ19WRVJfMTkgZG9uJ3Qgc3VwcG9ydCByZXNldHRp
bmcgdGhlDQo+ICsJICogdGFsbHkgY291bnRlcnMuDQo+ICsJICovDQo+ICsJaWYgKHRwLT5tYWNf
dmVyc2lvbiA+PSBSVExfR0lHQV9NQUNfVkVSXzE5KSB7DQo+ICsJCVJUTF9XMzIoQ291bnRlckFk
ZHJIaWdoLCAwKTsNCj4gKwkJUlRMX1czMihDb3VudGVyQWRkckxvdywgQ291bnRlclJlc2V0KTsN
Cg0KSSBjaGVjayB0aGVzZSB3aXRoIG91ciBlbmdpbmVlcnMsIGFuZCB0aGV5IHNheSB0aGUgYml0
IDYgfiA2MyBzaG91bGQgYmUgdGhlDQp2YWxpZCA2NCBieXRlIGFsaWdubWVudCBtZW1vcnkgYWRk
cmVzcy4gQWx0aG91Z2ggeW91IGRvbuKAmXQgd2FudCB0byBkdW1wDQp0aGUgY291bnRlcnMsIHRo
ZSBodyBtYXkgYWxzbyBjbGVhciB0aGUgZGF0YSBpbiB0aGUgbWVtb3J5IHdoaWNoIGlzIGluZGlj
YXRlZA0KYnkgYml0IDYgfiA2Mywgd2hlbiB5b3UgcmVzZXQgdGhlIGNvdW50ZXJzLg0KDQpCZXN0
IFJlZ2FyZHMsDQpIYXllcw0KDQo=
