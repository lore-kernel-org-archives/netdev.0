From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: slight optimization in ip6_dst_gc
Date: Wed, 21 May 2014 15:53:13 -0400 (EDT)
Message-ID: <20140521.155313.1750524856038712746.davem@davemloft.net>
References: <1400491828-14335-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbaEUTxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 15:53:15 -0400
In-Reply-To: <1400491828-14335-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <rongqing.li@windriver.com>
Date: Mon, 19 May 2014 17:30:28 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> entries is always greater than rt_max_size here, since if entries is less
> than rt_max_size, the fib6_run_gc function will be skipped
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thank you.
