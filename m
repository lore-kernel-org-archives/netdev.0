From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: phy: broadcom: Wirespeed/downshift
 support
Date: Thu, 24 Nov 2016 15:54:57 -0500 (EST)
Message-ID: <20161124.155457.427536248070283712.davem@davemloft.net>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41496 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933643AbcKXUzB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 15:55:01 -0500
In-Reply-To: <20161122194058.29820-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 22 Nov 2016 11:40:53 -0800

> This patch series adds support for the Broadcom Wirespeed, aka downsfhit feature
> utilizing the recently added ethtool PHY tunables.
> 
> Tested with two Gigabit link partners with a 4-wire cable having only 2 pairs
> connected.
> 
> Last patch in the series is a fix that was required for testing, which should
> make it to -stable, which I can submit separate against net if you prefer David.

Series applied to net-next, patch #5 applied also to 'net' and queued up for
-stable.

Thanks.
