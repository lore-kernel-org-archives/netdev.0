From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] irda: vlsi_ir: Remove casting the return value
 which is a void pointer
Date: Wed, 11 Sep 2013 16:13:11 -0400 (EDT)
Message-ID: <20130911.161311.1575478420902405049.davem@davemloft.net>
References: <004c01cead1c$d899f120$89cdd360$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab3IKUNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:13:13 -0400
In-Reply-To: <004c01cead1c$d899f120$89cdd360$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 09 Sep 2013 14:24:24 +0900

> Casting the return value which is a void pointer is redundant.
> The conversion from void pointer to any other pointer type is
> guaranteed by the C programming language.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
