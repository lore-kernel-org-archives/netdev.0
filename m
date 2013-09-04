From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sfc: check for allocation failure
Date: Tue, 03 Sep 2013 22:49:39 -0400 (EDT)
Message-ID: <20130903.224939.866623192858217581.davem@davemloft.net>
References: <20130902082828.GA30037@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936Ab3IDCtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:49:41 -0400
In-Reply-To: <20130902082828.GA30037@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 2 Sep 2013 12:04:42 +0300

> It upsets static analyzers when we don't check for allocation failure.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

This applies cleanly neither to net nor net-next, please send me a
version that does.

Thanks.
