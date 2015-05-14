From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] net: macb: OR vs AND typos
Date: Thu, 14 May 2015 00:49:24 -0400 (EDT)
Message-ID: <20150514.004924.1739796884775337118.davem@davemloft.net>
References: <20150512181524.GE5672@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, harini.katakam@xilinx.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbbENEt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 00:49:26 -0400
In-Reply-To: <20150512181524.GE5672@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 12 May 2015 21:15:24 +0300

> The bitwise tests are always true here because it uses '|' where '&' is
> intended.
> 
> Fixes: 98b5a0f4a228 ('net: macb: Add support for jumbo frames')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
