From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 00/10] net/mlx4: Mellanox driver update
 08-12-2013
Date: Thu, 19 Dec 2013 19:05:38 -0500 (EST)
Message-ID: <20131219.190538.1380568328493553000.davem@davemloft.net>
References: <1387480818-3932-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, yevgenyp@mellanox.com,
	netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756600Ab3LTAFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:05:40 -0500
In-Reply-To: <1387480818-3932-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 19 Dec 2013 21:20:08 +0200

> This patchset contains:
> 1. Support in ndo_get_phys_port_id added by Hadar.
> 2. Change the driver to use by default CQE/EQE size of 64 bytes done by Eyal.
>    This doubles the packet-rate  of the NIC.
> 3. Configure the XPS queue mapping on driver load - added by Ido.
> 4. Fixes for some small bugs done by Jenny and Matan
> 
> Patchset was applied and tested against commit: "2372175 lib: hash: follow-up
> fixups for arch hash"

Series applied, thank you.
