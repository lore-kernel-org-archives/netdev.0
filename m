From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hsr: use eth_hw_addr_random()
Date: Tue, 21 Feb 2017 13:25:34 -0500 (EST)
Message-ID: <20170221.132534.294291267061916342.davem@davemloft.net>
References: <20170221130459.5873-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754761AbdBUSZm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:25:42 -0500
In-Reply-To: <20170221130459.5873-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 21 Feb 2017 14:04:59 +0100

> Use eth_hw_addr_random() to set a random MAC address in order to make sure
> dev->addr_assign_type will be properly set to NET_ADDR_RANDOM.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
