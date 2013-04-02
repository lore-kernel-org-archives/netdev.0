From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Fix setting initial MAC address
Date: Tue, 02 Apr 2013 12:09:44 -0400 (EDT)
Message-ID: <20130402.120944.12749350952656234.davem@davemloft.net>
References: <1364910585-2963-1-git-send-email-yanb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, amirv@mellanox.com
To: yanb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932772Ab3DBQJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 12:09:46 -0400
In-Reply-To: <1364910585-2963-1-git-send-email-yanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>
Date: Tue,  2 Apr 2013 16:49:45 +0300

> Commit 6bbb6d9 "net/mlx4_en: Optimize Rx fast path filter checks" introduced a regression
> under which the MAC address read from the card was not converted correctly
> (the most significant byte was not handled), fix that.
> 
> Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Yan Burman <yanb@mellanox.com>

Applied.
