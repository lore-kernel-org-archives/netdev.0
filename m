From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] ipmr: change the prototype of
 ip_mr_forward().
Date: Tue, 23 Jul 2013 17:01:35 -0700 (PDT)
Message-ID: <20130723.170135.138102935819188687.davem@davemloft.net>
References: <1374322168-5115-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810Ab3GXABg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 20:01:36 -0400
In-Reply-To: <1374322168-5115-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Sat, 20 Jul 2013 15:09:28 +0300

> This patch changes the prototpye of the ip_mr_forward() method to return void
> instead of int.
> 
> The ip_mr_forward() method always returns 0; moreover, the return value of this
> method is not checked anywhere.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
