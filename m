From: "Meng, Jilin" <Jilin.Meng@emc.com>
Subject: Recall: [PATCH] net: Fix tentative IPv6 address due to DAD looping
 back
Date: Thu, 11 Apr 2013 01:36:26 +0000
Message-ID: <027526AF93736D4380632CD4F3B42B8002FC08@MX101CL02.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Meng, Jilin" <Jilin.Meng@emc.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hop-nat-141.emc.com ([168.159.213.141]:40847 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935224Ab3DKBhP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 21:37:15 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meng, Jilin would like to recall the message, "[PATCH] net: Fix tentative IPv6 address due to DAD looping back".