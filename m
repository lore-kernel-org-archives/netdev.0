From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 2/2] net: w5100: Use devm_ioremap_resource()
Date: Fri, 28 Feb 2014 16:58:01 -0500 (EST)
Message-ID: <20140228.165801.1904710640755558319.davem@davemloft.net>
References: <001501cf3448$9bc4f660$d34ee320$%han@samsung.com>
	<001601cf3448$ad6b8c30$0842a490$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, msink@permonline.ru
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbaB1V6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 16:58:03 -0500
In-Reply-To: <001601cf3448$ad6b8c30$0842a490$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Fri, 28 Feb 2014 14:48:16 +0900

> Use devm_ioremap_resource() in order to make the code simpler.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Also applied to net-next, thank you.
