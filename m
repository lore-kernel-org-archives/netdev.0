From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for-net] net/mlx4_en: Check device state when setting
 coalescing
Date: Thu, 12 Sep 2013 23:42:42 -0400 (EDT)
Message-ID: <20130912.234242.722667332812543306.davem@davemloft.net>
References: <1378998680-7546-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	gideonn@mellanox.com, eugenia@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab3IMDmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 23:42:44 -0400
In-Reply-To: <1378998680-7546-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 12 Sep 2013 18:11:20 +0300

> From: Eugenia Emantayev <eugenia@mellanox.com>
> 
> When the device is down, CQs are freed. We must check the device state
> to avoid issuing firmware commands on non existing CQs.
> 
> CC: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
