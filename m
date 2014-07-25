From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1] net/mlx4_en: mlx4_en_[gs]et_priv_flags()
 can be static
Date: Thu, 24 Jul 2014 23:36:48 -0700 (PDT)
Message-ID: <20140724.233648.1889102247675407245.davem@davemloft.net>
References: <1406182306-27436-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, fengguang.wu@intel.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaGYGgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:36:50 -0400
In-Reply-To: <1406182306-27436-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 24 Jul 2014 09:11:46 +0300

> From: Fengguang Wu <fengguang.wu@intel.com>
> 
> Fixes sparse warning intrduced by commit 0fef9d0 ("net/mlx4_en: Disable
> blueflame using ethtool private flags")
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thank you.
