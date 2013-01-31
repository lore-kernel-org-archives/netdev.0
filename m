From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/10] Mellanox Ethernet driver updates
 2013-01-30
Date: Thu, 31 Jan 2013 13:51:58 -0500 (EST)
Message-ID: <20130131.135158.206758800827480029.davem@davemloft.net>
References: <1359623231-4491-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207Ab3AaSwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 13:52:03 -0500
In-Reply-To: <1359623231-4491-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 31 Jan 2013 11:07:01 +0200

> Hi Dave,
> 
> This series contains updates to mlx4 driver.
> Majority of the patches are small bug fixes. Another patch is to expose through
> debugfs some HW resources to be used by external tools.
> 
> Patches done against net-next commit 1b13c97: "net/vxlan: Add ethtool drvinfo"
> 
> Changes from V0:
> - Removed patch "net/mlx4_en: Add debugfs support". Need to find a standard way
>   to do it, and no need to delay the other patches.

All applied, thanks.
