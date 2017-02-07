From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] Set the CMODE for mv88e6390 ports
Date: Tue, 07 Feb 2017 10:35:10 -0500 (EST)
Message-ID: <20170207.103510.1958145222092392552.davem@davemloft.net>
References: <1486234970-11300-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754984AbdBGPfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 10:35:24 -0500
In-Reply-To: <1486234970-11300-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat,  4 Feb 2017 20:02:48 +0100

> The mv88e6390 ports 9 & 10 allow there CMODE to be set. CMODE is part
> of what linux defines as phy-mode. Add the needed phy-modes to linux,
> and add code which will act upon the phy-mode property to configure
> the switch port.
> 
> These patches have been posted before as part of a bigger patchset
> which has now been broken up. I've added the received reviewed by
> tags, and added device tree documentation.

Series applied, thanks Andrew.
