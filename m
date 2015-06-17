From: Maninder Singh <maninder1.s@samsung.com>
Subject: Re: Re: [PATCH 1/1] net: replace if()/BUG with BUG_ON()
Date: Wed, 17 Jun 2015 05:04:12 +0000 (GMT)
Message-ID: <405153159.1166061434517448384.JavaMail.weblogic@epmlwas03c>
Reply-To: maninder1.s@samsung.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: base64
Cc: "willemb@google.com" <willemb@google.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"al.drozdov@gmail.com" <al.drozdov@gmail.com>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"eyal.birger@gmail.com" <eyal.birger@gmail.com>,
	"mst@redhat.com" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	PANKAJ MISHRA <pankaj.m@samsung.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:37902 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbbFQFEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 01:04:13 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NQ201SPXOR0HL70@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 17 Jun 2015 14:04:12 +0900 (KST)
MIME-version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRGF2aWQsIA0KDQo+PiBVc2UgQlVHX09OKGNvbmRpdGlvbikgaW5zdGVhZCBvZiBpZihjb25k
aXRpb24pL0JVRygpDQo+PiANCj4+IFNpZ25lZC1vZmYtYnk6IE1hbmluZGVyIFNpbmdoIDxtYW5p
bmRlcjEuc0BzYW1zdW5nLmNvbT4NCj4+IFJldmlld2VkLWJ5OiBBa2hpbGVzaCBLdW1hciA8YWto
aWxlc2gua0BzYW1zdW5nLmNvbT4NCg0KPllvdXIgZW1haWwgY2xpZW50IGNvcnJ1cHRlZCB0aGlz
IHBhdGNoLCBtYWtpbmcgaXQgdW51c2FibGUNCg0KSSByZXNlbnQgdGhlIHBhdGNoIHdpdGggZ2l0
IHNlbmQtbWFpbCAsIGl0IHJlc3VsdHMgb2ssIGhvcGVmdWxseSBpdCBkb2VzIG5vdCBjb3JydXB0
IGl0Lg0KDQpUaGFua3M=
