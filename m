From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] net/mlx5_core: Expose transobj APIs from
 mlx5 core
Date: Tue, 25 Aug 2015 16:24:02 -0700 (PDT)
Message-ID: <20150825.162402.240366276387800611.davem@davemloft.net>
References: <1440505800-5934-1-git-send-email-achiad@mellanox.com>
	<1440505800-5934-2-git-send-email-achiad@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ogerlitz@mellanox.com,
	saeedm@mellanox.com, talal@mellanox.com, yishaih@mellanox.com
To: achiad@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755979AbbHYXYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:24:03 -0400
In-Reply-To: <1440505800-5934-2-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>
Date: Tue, 25 Aug 2015 15:29:57 +0300

> From: Yishai Hadas <yishaih@mellanox.com>
> 
> Move transobj.h from the core library to include/linux/mlx5
> and expose its APIs.
> It enables using its functionality outside of mlx5 core.
> 
> Signed-off-by: Yishai Hadas <yishaih@mellanox.com>

You can submit this patch when you submit the upstream change that makes
use of this code in such a way, not beforehand.
