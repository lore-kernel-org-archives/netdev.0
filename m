From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] iph: use default get_stats
Date: Wed, 08 Jun 2011 17:06:51 -0700 (PDT)
Message-ID: <20110608.170651.1758511322695490429.davem@davemloft.net>
References: <20110608110913.54becfba@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab1FIAGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 20:06:52 -0400
In-Reply-To: <20110608110913.54becfba@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 8 Jun 2011 11:09:13 -0700

> This driver keeps stats in net_device stats therefore it
> does not need to define it's own get_stats hook.
> 
> Also, use standard format for net_device_ops (without &).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
