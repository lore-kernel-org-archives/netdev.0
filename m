From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 3/3] net: bgmac: use PHY subsystem for initializing
 PHY
Date: Tue, 31 Jan 2017 13:04:29 -0500 (EST)
Message-ID: <20170131.130429.1477789092223900995.davem@davemloft.net>
References: <20170128210832.26174-1-zajec5@gmail.com>
        <20170128210832.26174-4-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.mason@broadcom.com, f.fainelli@gmail.com, nbd@openwrt.org,
        netdev@vger.kernel.org, rafal@milecki.pl
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39572 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751469AbdAaSEb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:04:31 -0500
In-Reply-To: <20170128210832.26174-4-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This entire series is being held up because there is still questions about
whether this is programming the internal PHYs and therefore whether the
code should be placed elsewhere.

Can we please move the discussion forward?

Thank you.
