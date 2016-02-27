From: David Miller <davem@davemloft.net>
Subject: Re: [patch] rocker: fix an error code
Date: Sat, 27 Feb 2016 14:06:48 -0500 (EST)
Message-ID: <20160227.140648.1005754769609600947.davem@davemloft.net>
References: <20160227113143.GA19177@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, ying.xue@windriver.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756778AbcB0XBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 18:01:34 -0500
In-Reply-To: <20160227113143.GA19177@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 27 Feb 2016 14:31:43 +0300

> We intended to return PTR_ERR() here instead of 1.
> 
> Fixes: 1f9993f6825f ('rocker: fix a neigh entry leak issue')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
