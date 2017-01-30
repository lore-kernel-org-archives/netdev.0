From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: adaptec: starfire: add checks for dma mapping
 errors
Date: Sun, 29 Jan 2017 19:06:21 -0500 (EST)
Message-ID: <20170129.190621.1994881885581433999.davem@davemloft.net>
References: <20170123.125317.799337053139253880.davem@redhat.com>
        <1485554850-7726-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ionut@badula.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdA3APy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 19:15:54 -0500
In-Reply-To: <1485554850-7726-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 28 Jan 2017 01:07:30 +0300

> init_ring(), refill_rx_ring() and start_tx() don't check
> if mapping dma memory succeed.
> The patch adds the checks and failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied.
