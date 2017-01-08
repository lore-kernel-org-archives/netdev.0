From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mdio: Demote print from info to debug in
 mdio_device_register
Date: Sun, 08 Jan 2017 18:15:03 -0500 (EST)
Message-ID: <20170108.181503.1655247282531291254.davem@davemloft.net>
References: <20170107062759.32015-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdAHXPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 18:15:05 -0500
In-Reply-To: <20170107062759.32015-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri,  6 Jan 2017 22:27:59 -0800

> While it is useful to know which MDIO device is being registered, demote
> the dev_info() to a dev_dbg().
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
