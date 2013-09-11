From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] irda: donauboe: Remove casting the return value
 which is a void pointer
Date: Wed, 11 Sep 2013 16:13:05 -0400 (EDT)
Message-ID: <20130911.161305.594273554393723380.davem@davemloft.net>
References: <004b01cead1c$8e1678d0$aa436a70$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab3IKUNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:13:08 -0400
In-Reply-To: <004b01cead1c$8e1678d0$aa436a70$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 09 Sep 2013 14:22:19 +0900

> Casting the return value which is a void pointer is redundant.
> The conversion from void pointer to any other pointer type is
> guaranteed by the C programming language.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
