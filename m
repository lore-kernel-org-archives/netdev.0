From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 0/7] net/mlx4 features and fixes
Date: Sun, 27 Nov 2011 17:21:26 -0500 (EST)
Message-ID: <20111127.172126.135038174942098194.davem@davemloft.net>
References: <4ED1D0AB.5010804@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, oren@mellanox.co.il,
	amirv@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab1K0WVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 17:21:38 -0500
In-Reply-To: <4ED1D0AB.5010804@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 27 Nov 2011 07:54:51 +0200

> Hello David,
> 
> This is V2 ofa series of patches for mlx4_en driver.
> synchronized the different commits into a single series.
> 
> The changes from initial commit:
> 1. loobback support patch: control flags are not set on data path.
> 2. Setting number of RSS rings patch was removed for rework following the review.

All applied, thanks.
