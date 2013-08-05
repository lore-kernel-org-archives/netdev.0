From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net: mlx4: Staticize local functions
Date: Mon, 05 Aug 2013 11:10:32 -0700 (PDT)
Message-ID: <20130805.111032.1344382340050251795.davem@davemloft.net>
References: <002401ce91ba$d8025860$88070920$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com, eugenia@mellanox.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563Ab3HESKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 14:10:33 -0400
In-Reply-To: <002401ce91ba$d8025860$88070920$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 05 Aug 2013 18:04:51 +0900

> These local functions are used only in this file.
> Fix the following sparse warnings:
 ...
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
