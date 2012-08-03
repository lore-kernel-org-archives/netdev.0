From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 1/3] net/mlx4_en: loopbacked packets are dropped
 when SMAC=DMAC
Date: Fri, 03 Aug 2012 16:49:52 -0700 (PDT)
Message-ID: <20120803.164952.870934800327257347.davem@davemloft.net>
References: <1343990318-10744-1-git-send-email-yevgenyp@mellanox.co.il>
	<1343990318-10744-2-git-send-email-yevgenyp@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab2HCXtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 19:49:52 -0400
In-Reply-To: <1343990318-10744-2-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Fri,  3 Aug 2012 13:38:36 +0300

> From: Amir Vadai <amirv@mellanox.com>
> 
> Should NOT check SMAC=DMAC when:
> 1. loopback is turned on
> 2. validate_loopback is true.
> 
> Fixed it accordingly.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied.
