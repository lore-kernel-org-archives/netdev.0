From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wrap
 around
Date: Mon, 22 Aug 2011 05:15:45 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F642D8EDB85A@EXMAIL.ad.emulex.com>
References: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
	 <1314011613-4519-4-git-send-email-sathya.perla@emulex.com>
	 <1314013414.2307.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1314013658.2307.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:13325 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751504Ab1HVMQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 08:16:16 -0400
In-Reply-To: <1314013658.2307.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86
ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj5TZW50OiBNb25kYXksIEF1Z3VzdCAyMiwgMjAxMSA1
OjE4IFBNDQo+DQo+TGUgbHVuZGkgMjIgYW/Du3QgMjAxMSDDoCAxMzo0MyArMDIwMCwgRXJpYyBE
dW1hemV0IGEgw6ljcml0IDoNCj4NCj4+IFRoaXMgYWRkcyBhIHJhY2UgZm9yIGxvY2tsZXNzIFNO
TVAgcmVhZGVycyAoaW4gYmVfZ2V0X3N0YXRzNjQoKSkNCj4+DQo+PiBUaGV5IGNhbiBzZWUgdGhl
IDMyYml0IHZhbHVlIGdvaW5nIGJhY2t3YXJkLg0KPj4NCj4+IFlvdSBoYXZlIHRvIGJlIHZlcnkg
Y2FyZWZ1bCB0byByZWFkIHRoZSAqYWNjIG9uY2UsIGFuZCB3cml0ZSBpdCBvbmNlLg0KPg0KPlRo
ZSAid3JpdGUgb25jZSIgaXMgdGhlIG9ubHkgcmVxdWlyZW1lbnQuDQo+DQo+U29tZXRoaW5nIGxp
a2UgOg0KPg0KPnUzMiBuZXd2YWwgPSBoaSgqYWNjKSArIHZhbDsNCj4NCj5pZiAod3JhcHBlZCkN
Cj4JbmV3dmFsICs9IDY1NTM2Ow0KPkFDQ0VTU19PTkNFKCphY2MpID0gbmV3dmFsOw0KPg0KDQpF
cmljLA0KDQpJJ20gd29uZGVyaW5nIHdoeSB5b3UnZCBuZWVkIEFDQ0VTU19PTkNFKCkgaGVyZT8g
V291bGRuJ3QgdXNpbmcgdGhlIHRlbXAgdmFyaWFibGUgKG5ld3ZhbCkgYXMgeW91IHN1Z2dlc3Rl
ZCwNCmVuc3VyZSB0aGF0IHRoZSByZWFkZXIgZG9lc24ndCBzZWUgYSBoYWxmLWJha2VkIHZhbHVl
Pw0KDQo=
