From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sxgbe: make local functions static
Date: Sun, 20 Apr 2014 18:20:13 -0400 (EDT)
Message-ID: <20140420.182013.135413416005025932.davem@davemloft.net>
References: <004401cf5a25$bc8ed200$35ac7600$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bh74.an@samsung.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaDTWUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 18:20:15 -0400
In-Reply-To: <004401cf5a25$bc8ed200$35ac7600$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Thu, 17 Apr 2014 19:13:53 +0900

> Make local functions static, because these are used only in this
> file.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
