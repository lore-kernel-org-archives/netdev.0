From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] ipvlan: move the device check function
 into netdevice.h
Date: Tue, 09 Dec 2014 16:10:49 -0500 (EST)
Message-ID: <20141209.161049.472791412868456052.davem@davemloft.net>
References: <1417910013-13274-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbaLIVKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:10:51 -0500
In-Reply-To: <1417910013-13274-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sat,  6 Dec 2014 15:53:33 -0800

> Move the port check [ipvlan_dev_master()] and device check
> [ipvlan_dev_slave()] functions to netdevice.h and rename them
> netif_is_ipvlan_port() and netif_is_ipvlan() resp. to be
> consistent with macvlan api naming.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.
