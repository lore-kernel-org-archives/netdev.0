From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 0/4] mlx4 driver fixes for 4.0-rc
Date: Wed, 18 Mar 2015 15:23:25 -0400 (EDT)
Message-ID: <20150318.152325.904530778115978631.davem@davemloft.net>
References: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, talal@mellanox.com,
	hadarh@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbbCRTX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 15:23:28 -0400
In-Reply-To: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 18 Mar 2015 16:51:34 +0200

> Just few small fixes for the 4.0 rc cycle.
> 
> The fix from Moni addresses an issue from 4.0-rc1 so we
> just need it for net.
> 
> Eran's fix for off-by-one should go to 3.19.y too.

All applied and patch #2 queued up for -stable, thanks.
