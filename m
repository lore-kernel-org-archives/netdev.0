From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/mlx4_en: dereferencing freed memory
Date: Mon, 16 Jul 2012 22:58:53 -0700 (PDT)
Message-ID: <20120716.225853.1031106440346773611.davem@davemloft.net>
References: <20120711063407.GD11812@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, amirv@mellanox.com, ogerlitz@mellanox.com,
	alexg@mellanox.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab2GQF6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:58:54 -0400
In-Reply-To: <20120711063407.GD11812@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 11 Jul 2012 09:34:07 +0300

> We dereferenced "mclist" after the kfree().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
