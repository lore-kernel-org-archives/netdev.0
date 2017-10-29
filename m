From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: b53: Export b53_configure_vlan()
Date: Sun, 29 Oct 2017 12:13:57 +0900 (KST)
Message-ID: <20171029.121357.1422485599262931557.davem@davemloft.net>
References: <20171027225601.32194-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbdJ2DOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 23:14:02 -0400
In-Reply-To: <20171027225601.32194-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 27 Oct 2017 15:56:01 -0700

> bcm_sf2 and b53 replicate the same operations: clear all VLANs and set
> their ports to the default VLAN tag (1 for these devices) so export the
> b53 function doing just that.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
