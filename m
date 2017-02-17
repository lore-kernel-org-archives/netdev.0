From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethoc: Use eth_hw_addr_random()
Date: Fri, 17 Feb 2017 12:42:37 -0500 (EST)
Message-ID: <20170217.124237.2092631932159238593.davem@davemloft.net>
References: <20170216125432.9594-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        thierry.reding@gmail.com, colin.king@canonical.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934144AbdBQRwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 12:52:40 -0500
In-Reply-To: <20170216125432.9594-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 16 Feb 2017 13:54:32 +0100

> Use eth_hw_addr_random() to set a random dev_addr and update
> addr_assign_type instead of open-coding it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thanks.
