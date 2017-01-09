From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: dsa: select NET_SWITCHDEV
Date: Mon, 09 Jan 2017 17:18:03 -0500 (EST)
Message-ID: <20170109.171803.260484447476606800.davem@davemloft.net>
References: <20170109214926.20985-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        jiri@resnulli.us, rdunlap@infradead.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933090AbdAIWSF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:18:05 -0500
In-Reply-To: <20170109214926.20985-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  9 Jan 2017 16:49:26 -0500

> The support for DSA Ethernet switch chips depends on TCP/IP networking,
> thus explicit that HAVE_NET_DSA depends on INET.
> 
> DSA uses SWITCHDEV, thus select it instead of depending on it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> Tested-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks.
