From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: add documentation for BQL helpers
Date: Fri, 06 Sep 2013 14:47:53 -0400 (EDT)
Message-ID: <20130906.144753.748858149240201205.davem@davemloft.net>
References: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
	<1378483080-31632-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab3IFSry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 14:47:54 -0400
In-Reply-To: <1378483080-31632-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Fri, 6 Sep 2013 16:58:00 +0100

> Provide a kernel-doc comment documentation for the BQL helpers:
> - netdev_sent_queue
> - netdev_completed_queue
> - netdev_reset_queue
> 
> Similarly to how it is done for the other functions, the documentation
> only covers the function operating on struct net_device and not struct
> netdev_queue.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
