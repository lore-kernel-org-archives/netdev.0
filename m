From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: dsa: b53: Utilize common helpers for
 u64/MAC
Date: Fri, 06 Jan 2017 15:51:46 -0500 (EST)
Message-ID: <20170106.155146.136042982117088099.davem@davemloft.net>
References: <20170105190858.12623-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, volodymyr.bendiuga@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40890 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753339AbdAFUvs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:51:48 -0500
In-Reply-To: <20170105190858.12623-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  5 Jan 2017 11:08:58 -0800

> Utilize the two functions recently introduced: u64_to_ether() and
> ether_to_u64() instead of our own versions.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
