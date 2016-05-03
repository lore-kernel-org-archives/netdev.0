From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/12] Mellanox 100G ethernet SRIOV Upgrades
Date: Tue, 03 May 2016 12:12:54 -0400 (EDT)
Message-ID: <20160503.121254.1213266710265417601.davem@davemloft.net>
References: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	eranbe@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933433AbcECQM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 12:12:56 -0400
In-Reply-To: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please don't have two patch series pending for the same driver (mlx5) and
the same tree (net-next).

This makes things extremely confusing (is patch set #2 dependent upon #1?
what if I ask for changes to patch set #1?).

So always let the first patch series get fully resolved before sending
the second series.

I'm tossing this series out.
