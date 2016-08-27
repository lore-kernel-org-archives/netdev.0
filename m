From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Utilize mask clear/set
 helpers in bcm_sf2_intr_disable
Date: Fri, 26 Aug 2016 21:34:35 -0700 (PDT)
Message-ID: <20160826.213435.1659853301503061871.davem@davemloft.net>
References: <1472163821-7142-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbcH0Eel (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 00:34:41 -0400
In-Reply-To: <1472163821-7142-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 25 Aug 2016 15:23:41 -0700

> And while at it, remove the unecessary writing of zeroes to the CPU_MASK_CLEAR
> register since it has no functional use.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
