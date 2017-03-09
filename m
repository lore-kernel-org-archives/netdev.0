From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mediatek: Use eth_hw_addr_random()
Date: Thu, 09 Mar 2017 13:17:42 -0800 (PST)
Message-ID: <20170309.131742.999389968350413095.davem@davemloft.net>
References: <20170307152710.19458-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44438 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752174AbdCIVRo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 16:17:44 -0500
In-Reply-To: <20170307152710.19458-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue,  7 Mar 2017 16:27:10 +0100

> Use eth_hw_addr_random() to set a random dev_addr and update
> addr_assign_type instead of open-coding it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
