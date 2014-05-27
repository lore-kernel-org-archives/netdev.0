From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: Defer VF initialization till PF is
 fully initialized
Date: Tue, 27 May 2014 15:00:46 -0400 (EDT)
Message-ID: <20140527.150046.2151081593443568769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbaE0TAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 15:00:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If you want me to submit this for -stable, you will need to do the backports for
me, as this patch doesn't even come close to applying to v3.14.4, thank you.
