From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Remove unused pointer in vortex_eisa_cleanup()
Date: Sun, 09 Feb 2014 19:06:35 -0800 (PST)
Message-ID: <20140209.190635.107877555024696798.davem@davemloft.net>
References: <20140208181117.6776b154@spike>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org
To: cengelma@gmx.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbaBJDGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 22:06:36 -0500
In-Reply-To: <20140208181117.6776b154@spike>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Engelmayer <cengelma@gmx.at>
Date: Sat, 8 Feb 2014 18:11:17 +0100

> Remove unused network device private data pointer 'vp' in function
> vortex_eisa_cleanup(). Detected by Coverity: CID 139826.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Applied.
