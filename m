From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: add check for dma mapping error in
 start_xmit()
Date: Sat, 19 Nov 2016 10:29:14 -0500 (EST)
Message-ID: <20161119.102914.2049594778546810370.davem@davemloft.net>
References: <1479508810-30476-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752975AbcKSP3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 10:29:21 -0500
In-Reply-To: <1479508810-30476-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 19 Nov 2016 01:40:10 +0300

> at91ether_start_xmit() does not check for dma mapping errors.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied, thanks.
