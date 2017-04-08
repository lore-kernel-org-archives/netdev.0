From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: Receive path simplifications
Date: Sat, 08 Apr 2017 13:49:54 -0700 (PDT)
Message-ID: <20170408.134954.1309724018854780313.davem@davemloft.net>
References: <20170408155523.20447-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, sean.wang@mediatek.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53036 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750982AbdDHUt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 16:49:56 -0400
In-Reply-To: <20170408155523.20447-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  8 Apr 2017 08:55:20 -0700

> This patch series does factor the common code found in all tag implementations
> into dsa_switch_rcv(). The original motivation was to add GRO support, but this
> may be a lot of work with unclear benefits at this point.
> 
> Changes in v2:
> - take care of tag_mtk.c in the process

Series applied, thanks.
