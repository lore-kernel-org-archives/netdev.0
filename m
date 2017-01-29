From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: micrel: KSZ8795 do not set
 SUPPORTED_[Asym_]Pause
Date: Sun, 29 Jan 2017 18:45:45 -0500 (EST)
Message-ID: <20170129.184545.793750378993214147.davem@davemloft.net>
References: <20170127203903.19171-1-sean.nyekjaer@prevas.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: sean.nyekjaer@prevas.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdA2Xpr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 18:45:47 -0500
In-Reply-To: <20170127203903.19171-1-sean.nyekjaer@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
Date: Fri, 27 Jan 2017 21:39:03 +0100

> As pr commit "net: phy: phy drivers should not set SUPPORTED_[Asym_]Pause"
> this phy driver should not set these feature bits.
> 
> Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
> Fixes: 9d162ed69f51 ("net: phy: micrel: add support for KSZ8795")

Applied.
