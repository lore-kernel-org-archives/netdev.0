From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/11] Mellanox ethernet driver updates
 Jan-27-2015
Date: Tue, 27 Jan 2015 17:13:23 -0800 (PST)
Message-ID: <20150127.171323.238151164961750703.davem@davemloft.net>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757924AbbA1BNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 20:13:24 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 27 Jan 2015 15:57:58 +0200

> This patchset introduces some bug fixes, code cleanups and support in a new
> firmware event called recoverable error events.
> 
> Patches were applied and tested against commit b8665c6 ("net: dsa/mv88e6352:
> make mv88e6352_wait generic")
> 
> Changes from V0:
> - Patch 6/11 ("net/mlx4_core: Fix struct mlx4_vhcr_cmd to make implicit padding
>   explicit"):
>   - Removed __packed
>   - Rephrased commit message
> 
> - Added a new patch by Majd ("net/mlx4_core: Update the HCA core clock frequency
>   after INIT_PORT")

Series applied, thanks.
