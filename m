From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: using non collapsed CQ on TX
Date: Tue, 15 Nov 2011 16:52:19 -0500 (EST)
Message-ID: <20111115.165219.1459508904321862383.davem@davemloft.net>
References: <4EC23E94.2030607@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756633Ab1KOVwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 16:52:25 -0500
In-Reply-To: <4EC23E94.2030607@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 15 Nov 2011 12:27:32 +0200

> Moving to regular Completion Queue implementation (not collapsed)
> Completion for each transmitted packet is written to new entry.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Can the people maintaining the Mellanox driver please coordinate
your efforts?

I should not be seeing multiple engineers submit seperate patches
on the same exact day to the mlx4 driver.

One person should be in charge for submitting all pending patches,
adding "From: " lines to the body of the commit message (as needed) to
indicate authorship properly.
