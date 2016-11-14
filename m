From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mdio: Demote print from info to debug in
 mdio_driver_register
Date: Mon, 14 Nov 2016 16:41:10 -0500 (EST)
Message-ID: <20161114.164110.1725631798213652784.davem@davemloft.net>
References: <20161114030117.25169-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41608 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932462AbcKNVlM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 16:41:12 -0500
In-Reply-To: <20161114030117.25169-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun, 13 Nov 2016 19:01:17 -0800

> While it is useful to know which MDIO driver is being registered, demote
> the pr_info() to a pr_debug().
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
