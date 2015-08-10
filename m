From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/7] mlxsw: Couple of fixes/adjustments
Date: Sun, 09 Aug 2015 22:54:46 -0700 (PDT)
Message-ID: <20150809.225446.1865081424057668746.davem@davemloft.net>
References: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885AbbHJFyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 01:54:47 -0400
In-Reply-To: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  6 Aug 2015 16:41:51 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido Schimmel (5):
>   mlxsw: Call free_netdev when removing port
>   mlxsw: Make system port to local port mapping explicit
>   mlxsw: Simplify mlxsw_sx_port_xmit function
>   mlxsw: Use correct skb length when dumping payload
>   mlxsw: Fix use-after-free bug in mlxsw_sx_port_xmit
> 
> Jiri Pirko (2):
>   mlxsw: Make pci module dependent on HAS_DMA and HAS_IOMEM
>   mlxsw: Strip FCS from incoming packets

Series applied, thanks.
