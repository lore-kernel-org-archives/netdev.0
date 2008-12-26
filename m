From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] mlx4_en: Memory leak on completion queue free
Date: Thu, 25 Dec 2008 18:16:10 -0800 (PST)
Message-ID: <20081225.181610.141840360.davem@davemloft.net>
References: <494F6524.1030301@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbYLZCQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 21:16:08 -0500
In-Reply-To: <494F6524.1030301@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 22 Dec 2008 12:00:04 +0200

> If port is being destroyed without being activated before,
> CQ resources are not freed.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.

