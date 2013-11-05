From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] mlx5_core: delete some dead code
Date: Tue, 05 Nov 2013 15:51:53 -0500 (EST)
Message-ID: <20131105.155153.1035193448394208433.davem@davemloft.net>
References: <20131103070326.GA3051@mtldesk30>
	<20131104222056.GA4248@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829Ab3KEU4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 15:56:41 -0500
In-Reply-To: <20131104222056.GA4248@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 5 Nov 2013 01:20:56 +0300

> The printk() looks like it is left over debug code.  I have removed it.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2:  Remove the printk instead of moving it infront of the return.

This doesn't apply to the current tree, I suspect some recent changes made
this fix no longer applicable.  Please take a look.

Thanks!
