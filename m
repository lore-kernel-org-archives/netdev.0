From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Remove unused neigh argument for
 icmp6_dst_alloc() and its callers.
Date: Fri, 18 Jan 2013 14:41:55 -0500 (EST)
Message-ID: <20130118.144155.209998585502080897.davem@davemloft.net>
References: <50F93958.6080603@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905Ab3ARTl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:41:57 -0500
In-Reply-To: <50F93958.6080603@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 18 Jan 2013 21:00:24 +0900

> Because of rt->n removal, we do not need neigh argument any more.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
