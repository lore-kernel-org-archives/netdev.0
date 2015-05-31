From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/4] mlx4 driver update, May 28, 2015
Date: Sat, 30 May 2015 23:35:55 -0700 (PDT)
Message-ID: <20150530.233555.1975990367045189657.davem@davemloft.net>
References: <1433053818-30251-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	talal@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbbEaGf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 02:35:56 -0400
In-Reply-To: <1433053818-30251-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 31 May 2015 09:30:14 +0300

> The 1st patch fixes an issue with a function running DPDK overriding 
> broadcast steering rules set by other functions. Please add this one 
> to your -stable queue.
> 
> The rest of the series from Matan and Ido deals with scaling the number 
> of IRQs that serve RoCE applications to be in par with the Ethernet driver.

Series applied, thanks Or.
