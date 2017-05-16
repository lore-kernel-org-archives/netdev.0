From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Remove residual magic from PHY drivers
Date: Tue, 16 May 2017 15:58:31 -0400 (EDT)
Message-ID: <20170516.155831.1664076050609953649.davem@davemloft.net>
References: <1494952151-3040-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53116 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751577AbdEPT6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:58:33 -0400
In-Reply-To: <1494952151-3040-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 16 May 2017 18:29:11 +0200

> commit fa8cddaf903c ("net phylib: Remove unnecessary condition check in phy")
> removed the only place where the PHY flag PHY_HAS_MAGICANEG was
> checked. But it left the flag being set in the drivers. Remove the flag.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied to net-next, thanks.
