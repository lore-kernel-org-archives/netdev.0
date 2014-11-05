From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: move INET6_MATCH() to
 include/net/inet6_hashtables.h
Date: Wed, 05 Nov 2014 17:00:58 -0500 (EST)
Message-ID: <20141105.170058.1989630760381051261.davem@davemloft.net>
References: <1415127587-29030-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaKEWBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 17:01:00 -0500
In-Reply-To: <1415127587-29030-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  4 Nov 2014 10:59:47 -0800

> It is only used in net/ipv6/inet6_hashtables.c.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
