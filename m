From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: axienet: use eth_hw_addr_random()
Date: Mon, 06 Mar 2017 17:16:06 -0800 (PST)
Message-ID: <20170306.171606.1653030249459977907.davem@davemloft.net>
References: <20170228112112.29450-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50912 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754661AbdCGBYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 20:24:40 -0500
In-Reply-To: <20170228112112.29450-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 28 Feb 2017 12:21:12 +0100

> Use eth_hw_addr_random() to set a random MAC address in order to make
> sure ndev->addr_assign_type will be properly set to NET_ADDR_RANDOM.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thanks.
