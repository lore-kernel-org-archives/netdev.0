From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] tcp: Change tcp_slow_start function to
 return void
Date: Tue, 30 Sep 2014 17:09:39 -0400 (EDT)
Message-ID: <20140930.170939.1856502943420780454.davem@davemloft.net>
References: <1412041795-5664-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaI3VJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 17:09:40 -0400
In-Reply-To: <1412041795-5664-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue, 30 Sep 2014 09:49:55 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> No caller uses the return value, so make this function return void.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
