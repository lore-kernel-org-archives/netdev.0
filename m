From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/2] net: w5300: Use devm_ioremap_resource()
Date: Fri, 28 Feb 2014 16:57:51 -0500 (EST)
Message-ID: <20140228.165751.2216876929763684913.davem@davemloft.net>
References: <001501cf3448$9bc4f660$d34ee320$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, msink@permonline.ru
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbaB1V5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 16:57:53 -0500
In-Reply-To: <001501cf3448$9bc4f660$d34ee320$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Fri, 28 Feb 2014 14:47:47 +0900

> Use devm_ioremap_resource() in order to make the code simpler.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied to net-next.
