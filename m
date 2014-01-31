From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: allow setting mac address of loopback device
Date: Thu, 30 Jan 2014 16:27:11 -0800 (PST)
Message-ID: <20140130.162711.1746399773464232016.davem@davemloft.net>
References: <1391038731-7501-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	edumazet@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbaAaA1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 19:27:11 -0500
In-Reply-To: <1391038731-7501-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 29 Jan 2014 15:38:51 -0800

> We are trying to mirror the local traffic from lo to eth0,
> allowing setting mac address of lo to eth0 would make
> the ether addresses in these packets correct, so that
> we don't have to modify the ether header again.
> 
> Since usually no one cares about its mac address (all-zero),
> it is safe to allow those who care to set its mac address.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Please resubmit when the net-next tree opens back up.

Thank you.
