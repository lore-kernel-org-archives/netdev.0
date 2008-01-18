From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv4: Enable use of 240/4 address space
Date: Fri, 18 Jan 2008 11:15:24 +0900 (JST)
Message-ID: <20080118.111524.102545566.yoshfuji@linux-ipv6.org>
References: <20080118.102635.01689255.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.64.0801180242270.14025@fbirervta.pbzchgretzou.qr>
	<20080118.111319.30002290.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ak@suse.de, vaf@cisco.com,
	yoshfuji@linux-ipv6.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35506 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758668AbYARCPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 21:15:13 -0500
In-Reply-To: <20080118.111319.30002290.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080118.111319.30002290.yoshfuji@linux-ipv6.org> (at Fri, 18 Jan 2008 11:13:19 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> Assuming IN_BADCLASS() is still there, we should not reuse the name
> of "ipv6_is_badclass" because the their meanings are different.

Again, ipv4_is_badclass()....
My hands almost automatically type "6" after "ipv"...

--yoshfuji
