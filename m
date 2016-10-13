From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: axienet: Remove unused parameter from
 __axienet_device_reset
Date: Thu, 13 Oct 2016 12:15:57 -0400 (EDT)
Message-ID: <20161013.121557.1377537577304981995.davem@davemloft.net>
References: <20161013112833.7581-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756675AbcJMQYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 12:24:17 -0400
In-Reply-To: <20161013112833.7581-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 13 Oct 2016 13:28:33 +0200

> The dev parameter passed to __axienet_device_reset() is not used inside
> the function, so remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
