From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/10] Mellanox driver updates 2013-06-25
Date: Tue, 25 Jun 2013 16:30:22 -0700 (PDT)
Message-ID: <20130625.163022.904170172910029930.davem@davemloft.net>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab3FYXaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:30:23 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 25 Jun 2013 12:09:28 +0300

> This patch set contains some small fixes to mlx4_core and mlx4_en.
> 
> Amir is OOO and he passed the stick to me on this series.
> 
> The patches were applied and tested on commit d3c5f47ee2 "net: Restore 
> unintentional reverts." plus Eric's patch "mlx4: allow order-0 memory 
> allocations in RX path" from http://patchwork.ozlabs.org/patch/253575/ 
> that I just acknowledged.
> 
> Changes from V0:
> - dropped patch 1/11 as this is handled by Eric's change
> - addressed feedback on patch 6/10: Add prints when TX timeout occurs
>   - en_info => en_warn
>   - Use single line for warning message
>   - Update change log

Series applied, thanks.
