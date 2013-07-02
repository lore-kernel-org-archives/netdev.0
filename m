From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: remove fib_update_nh_saddrs()
 declaration.
Date: Tue, 02 Jul 2013 00:34:06 -0700 (PDT)
Message-ID: <20130702.003406.44513900444364376.davem@davemloft.net>
References: <1372706385-30895-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794Ab3GBHeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 03:34:07 -0400
In-Reply-To: <1372706385-30895-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Mon,  1 Jul 2013 22:19:45 +0300

> This patch removes the fib_update_nh_saddrs() declaration from
> include/net/ip_fib.h, as the fib_update_nh_saddrs() method was removed in 
> coomit 436c3b6 ("ipv4: Invalidate nexthop cache nh_saddr more correctly").
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks Rami.
