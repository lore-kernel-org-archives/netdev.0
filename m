From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] Mellanox 100G mlx5 fixes#2 for 4.7-rc
Date: Wed, 29 Jun 2016 04:30:16 -0400 (EDT)
Message-ID: <20160629.043016.1770660936415930624.davem@davemloft.net>
References: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcF2Iaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 04:30:46 -0400
In-Reply-To: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Mon, 27 Jun 2016 12:08:31 +0300

> Hi Dave,
> 
> The following series provides one-liners fixes for mlx5 driver plus one
> medium patch to reorganize ethtool counters reporting.
> 
> Highlights:
> 	- Added MODIFY_FLOW_TABLE to command strings table
> 	- Add ConnectX-5 PCIe 4.0 to list of supported devices
> 	- Rename ASYNC_EVENTS enum
> 	- Enable BlueFlame only when supported by device
> 	- Avoid adding same vxlan port twice
> 	- Report the correct number of PFC counters
> 	- Reorganize ethtool reported counters and remove duplications

Series applied, thanks.
