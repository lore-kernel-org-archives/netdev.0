From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Mon, 1 Feb 2016 16:55:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD25BC@AcuExch.aculab.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129.110634.1678121731419241040.davem@davemloft.net>
	 <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129194434.GC17127@oracle.com>
	 <1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0UdXBHocMwdcQHHd5bGMUofEH6ENox=Jw_vLEn3kMonmhA@mail.gmail.com>
	 <1454103195.7627.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0Udwjgmbwd2StNm-e-02Th4NHetb_FMbrU=KOCHf_90YbA@mail.gmail.com>
 <1454106518.7627.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.190]:57520 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510AbcBAQ6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 11:58:13 -0500
In-Reply-To: <1454106518.7627.92.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDI5IEphbnVhcnkgMjAxNiAyMjoyOQ0KLi4uDQo+
IE9uIG1vZGVybiBpbnRlbCBjcHVzLCB0aGlzIGRvZXMgbm90IG1hdHRlciBhdCBhbGwsIHN1cmUu
IEl0IHRvb2sgYSB3aGlsZQ0KPiBiZWZvcmUgInJlcCBtb3ZzYiIgZmluYWxseSBkaWQgdGhlIHJp
Z2h0IHRoaW5nLg0KDQpVbmZvcnR1bmF0ZWx5IG1lbWNweV90b19pbygpIGV0YyBub3cgbWFwIHRv
ICdyZXAgbW92c2InLCBhbmQgdGhhdCBjYW4NCm9ubHkgYmUgb3B0aW1pc2llZCBmb3IgY2FjaGVk
IGFkZHJlc3Nlcy4NCg0KU28gY29waWVzIHRvL2Zyb20gcGNpZSBzcGFjZSBnZXQgZG9uZSBhcyBi
eXRlIGNvcGllcywgc2xvd2VyIHRoYW4gc2xvdy4NCg0KVGhlIHNhbWUgaXMgdHJ1ZSB3aGVuIHVz
ZXNwYWNlIGhhcyB1c2VkIG1tYXAoKSB0byBkaXJlY3RseSBhY2Nlc3MNCnBjaWUgbWVtb3J5Lg0K
DQpUaGVyZSBpc24ndCBhIHN0YW5kYXJkIHdyYXBwZXIgdGhhbiBnZW5lcmF0ZXMgJ3JlcCBtb3Zz
ZCcuDQoNCglEYXZpZA0KDQo=
