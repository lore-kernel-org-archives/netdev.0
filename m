From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net/mlx5e: Kconfig fixes for VxLAN
Date: Mon, 09 May 2016 00:21:46 -0400 (EDT)
Message-ID: <20160509.002146.1708967902176028900.davem@davemloft.net>
References: <1462708525-23545-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	eranbe@mellanox.com, matt@mellanox.com, arnd@arndb.de
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbcEIEVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:21:50 -0400
In-Reply-To: <1462708525-23545-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun,  8 May 2016 14:55:23 +0300

> Reposting to net the build errors fixes posted by Arnd last week.
> 
> Originally Arnd posted those fixes to net-next, while the issue
> is also seen in net.  For net-next a different approach is required 
> for fixing the issue as VXLAN and Device Drivers are no longer
> dependent, but there is no harm for those fixes to get into net-next.
> 
> Optionally, once net is merged into net-next we can 
> Revert "net/mlx5e: make VXLAN support conditional" as the 
> CONFIG_MLX5_CORE_EN_VXLAN will no longer be required.
> 
> Applied on top: 288928658583 ('mlxsw: spectrum: Add missing rollback in flood configuration')

Series applied, thanks.
