From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] net: dsa: mv88e6xxx: Global (1)
 cosmetics
Date: Fri, 30 Sep 2016 01:26:38 -0400 (EDT)
Message-ID: <20160930.012638.776027814557694387.davem@davemloft.net>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932836AbcI3F0n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 01:26:43 -0400
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 29 Sep 2016 12:21:52 -0400

> The Global (1) internal SMI device of Marvell switches is a set of
> registers providing support to different units for MAC addresses (ATU),
> VLANs (VTU), PHY polling (PPU), etc.
 ...

Looks like a very nice set of cleanups to me.

Series applied, thanks!
