From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1] net/mlx4_en: Limit the RFS filter IDs to be <
 RPS_NO_FILTER
Date: Thu, 26 Jul 2012 00:24:08 -0700 (PDT)
Message-ID: <20120726.002408.1506166926638883156.davem@davemloft.net>
References: <1343287276-21584-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oren@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	bhutchings@solarflare.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab2GZHYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 03:24:11 -0400
In-Reply-To: <1343287276-21584-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 26 Jul 2012 10:21:16 +0300

> From: Amir Vadai <amirv@mellanox.com>
> 
> RFS filter id can't have the special value RPS_NO_FILTER,
> need to skip it when allocating id's.
> 
> CC: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
