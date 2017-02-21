From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnxt_en: use eth_hw_addr_random()
Date: Tue, 21 Feb 2017 13:34:02 -0500 (EST)
Message-ID: <20170221.133402.1580290226499266004.davem@davemloft.net>
References: <20170221142728.604-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751326AbdBUSeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:34:04 -0500
In-Reply-To: <20170221142728.604-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 21 Feb 2017 15:27:28 +0100

> Use eth_hw_addr_random() to set a random MAC address in order to make
> sure bp->dev->addr_assign_type will be properly set to NET_ADDR_RANDOM.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
