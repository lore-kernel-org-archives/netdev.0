From: Steven Caron <steven.caron@genband.com>
Subject: [PATCH  v1 0/1]  ipv4: Prevent malformed UFO fragments in
 ip_append_page
Date: Mon, 13 Jun 2016 14:01:09 +0000
Message-ID: <6A051441C8B95A448E49718A747690B901CA76C848@gbplmail03.genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-181.mimecast.com ([216.205.24.181]:49006 "EHLO
	us-smtp-delivery-181.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1424009AbcFMOCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 10:02:08 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpSZXN1Ym1pdHRpbmcgd2l0aCBzaWdub2ZmLg0KDQpUaGlzIGlzIGEgZml4IGZvciBtYWxmb3Jt
ZWQgVUZPIHBhY2tldHMgc2VlbiB3aGVuIHVzaW5nIE5GUyBvdmVyIFVEUC4NCkl0J3MgaW4gdGhl
IHNhbWUgdmVpbiBhcyBhbmQgY29tcGxlbWVudHMgZDliZTRmN2E2ZjVhOGRhMy4NCg0KbmV0L2lw
djQvaXBfb3V0cHV0LmMgfCAgICAyICstDQogMSBmaWxlcyBjaGFuZ2VkLCAxIGluc2VydGlvbnMo
KyksIDEgZGVsZXRpb25zKC0pDQoNClRoYW5rcywgDQoNClN0ZXZlbg0K
