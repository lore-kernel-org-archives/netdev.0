From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6]: Fix routing by fwmark
Date: Sat, 26 Aug 2006 20:39:53 +0900 (JST)
Message-ID: <20060826.203953.88499916.yoshfuji@linux-ipv6.org>
References: <44F02C5E.3070701@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:20747 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964941AbWHZLiE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 07:38:04 -0400
To: kaber@trash.net, davem@davemloft.net
In-Reply-To: <44F02C5E.3070701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <44F02C5E.3070701@trash.net> (at Sat, 26 Aug 2006 13:11:26 +0200), Patrick McHardy <kaber@trash.net> says:

> Fix mark comparison, also dump the mask to userspace when the mask is zero,
> but the mark is not (in which case the mark is dumped, so the mask is needed
> to make sense of it).
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

What a shame... Thank you for catching this.

--yoshfuji
