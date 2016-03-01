From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/9] mlx5 driver updates
Date: Tue, 01 Mar 2016 14:51:34 -0500 (EST)
Message-ID: <20160301.145134.1897442242357830301.davem@davemloft.net>
References: <1456846942-15082-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, eranbe@mellanox.com,
	talal@mellanox.com, majd@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbcCATvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 14:51:36 -0500
In-Reply-To: <1456846942-15082-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You guys need to get your act together.

I'm not going to allow two sets of parallel sets of changes to
one driver you guys maintain to be submitted at once.

Period.  I don't care why, or if things don't overlap, you need
to coordinate your submissions strictly.

We have this series, and the one that adds the flower et al.  offload.
Sorry, I'm not going to allow that especially considering what has
happened in the past.

Get one of these accepted first, then you can submit the other one.

I'm tossing all of these changes, resubmit the one you want to be
applied first.

Thanks.
