From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: rtnl_link_register() sanity test
Date: Wed, 14 Dec 2011 02:47:05 -0500 (EST)
Message-ID: <20111214.024705.1350239353552946938.davem@davemloft.net>
References: <1323808281-9967-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<20111213.160810.785264274549847462.davem@davemloft.net>
	<1323812280.2846.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323Ab1LNHrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 02:47:13 -0500
In-Reply-To: <1323812280.2846.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Dec 2011 22:38:00 +0100

> Before adding a struct rtnl_link_ops into link_ops list, check it doesnt
> clash with a prior one.
> 
> Based on a previous patch from Alexander Smirnov
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Applied.
