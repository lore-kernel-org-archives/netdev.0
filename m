From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] natsemi: add checks for dma mapping errors
Date: Sat, 19 Dec 2015 12:59:07 -0500 (EST)
Message-ID: <20151219.125907.1209644088992518899.davem@davemloft.net>
References: <56754855.6080808@ispras.ru>
	<1450527229-6454-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965060AbbLSR7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 12:59:09 -0500
In-Reply-To: <1450527229-6454-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 19 Dec 2015 15:13:49 +0300

> refill_rx() and start_tx() do not check if mapping dma memory succeed.
> The patch adds the checks and failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied, thanks.
