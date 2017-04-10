From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mt7530: Include gpio/consumer.h for
 GPIO functions
Date: Sun, 09 Apr 2017 18:29:19 -0700 (PDT)
Message-ID: <20170409.182919.1213834343222957819.davem@davemloft.net>
References: <20170408155202.20145-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sean.wang@mediatek.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbdDJB3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 21:29:21 -0400
In-Reply-To: <20170408155202.20145-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  8 Apr 2017 08:52:02 -0700

> Fixes build errors seen with CONFIG_GPIOLIB disabled and warnings enabled:
 ...
> Fixes: b8f126a8d543 ("net-next: dsa: add dsa support for Mediatek MT7530 switch")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
