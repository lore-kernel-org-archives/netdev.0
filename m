From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: mlx4_en_[gs]et_priv_flags() can
 be static
Date: Wed, 23 Jul 2014 15:00:07 -0700 (PDT)
Message-ID: <20140723.150007.1891339388720515413.davem@davemloft.net>
References: <1406097386-11034-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, fengguang.wu@intel.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933437AbaGWWAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 18:00:08 -0400
In-Reply-To: <1406097386-11034-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed, 23 Jul 2014 09:36:26 +0300

> From: Fengguang Wu <fengguang.wu@intel.com>
> 
> Fixes sparse warning intrduced by commit 0fef9d0 ("net/mlx4_en: Disable
> blueflame using ethtool private flags")
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

This doesn't apply to net-next.
