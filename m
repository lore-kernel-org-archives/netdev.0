From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] netdevice: Add a function to check
 macvlan port
Date: Tue, 09 Dec 2014 16:10:37 -0500 (EST)
Message-ID: <20141209.161037.2159961435986260472.davem@davemloft.net>
References: <1417909984-13133-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbaLIVKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:10:40 -0500
In-Reply-To: <1417909984-13133-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sat,  6 Dec 2014 15:53:04 -0800

> Similar to a check for macvlan device, netif_is_macvlan(), add
> another function to check if a device is used as macvlan port.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.
