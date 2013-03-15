From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Documentation: fix neigh/default/gc_thresh1
 default value.
Date: Fri, 15 Mar 2013 09:12:36 -0400 (EDT)
Message-ID: <20130315.091236.2207512762204897663.davem@davemloft.net>
References: <1363337387-9536-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab3CONMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 09:12:20 -0400
In-Reply-To: <1363337387-9536-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 15 Mar 2013 16:49:47 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The default value is 128, not 256
> 	#grep gc_thresh1 net/ -rI
> 	net/decnet/dn_neigh.c:	.gc_thresh1 =			128,
> 	net/ipv6/ndisc.c:	.gc_thresh1 =	 128,
> 	net/ipv4/arp.c:	.gc_thresh1	= 128,
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
