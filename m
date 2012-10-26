From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] mlx4 fixes
Date: Fri, 26 Oct 2012 03:34:58 -0400 (EDT)
Message-ID: <20121026.033458.481542962084139097.davem@davemloft.net>
References: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756554Ab2JZHfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 03:35:03 -0400
In-Reply-To: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 25 Oct 2012 13:12:46 +0200

> Dotan Barak (1):
>   net/mlx4_core: Unmap UAR also in the case of error flow
> 
> Jack Morgenstein (1):
>   net/mlx4_en: Fix double-release-range in tx-rings
> 
> Moni Shoua (1):
>   net/mlx4_en: Don't use vlan tag value as an indication for vlan presence

All applied, thanks.
