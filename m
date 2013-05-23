From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: use ipv6_addr_scope() helper
Date: Thu, 23 May 2013 01:18:27 -0700 (PDT)
Message-ID: <20130523.011827.881612209960741444.davem@davemloft.net>
References: <1369237942-24533-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab3EWIS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 04:18:28 -0400
In-Reply-To: <1369237942-24533-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 22 May 2013 23:52:22 +0800

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK could be replaced
> by ipv6_addr_scope(), which is slightly faster.
> 
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
