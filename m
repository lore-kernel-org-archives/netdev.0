From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 0/3] net-next: Broadcom PHY driver cleanup
Date: Wed, 25 Jan 2017 23:14:05 -0500 (EST)
Message-ID: <20170125.231405.890954133887623747.davem@davemloft.net>
References: <20170125200027.14387-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, jaedon.shin@gmail.com,
        netdev@vger.kernel.org, rafal@milecki.pl
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752743AbdAZEOH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 23:14:07 -0500
In-Reply-To: <20170125200027.14387-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Wed, 25 Jan 2017 21:00:24 +0100

> I will probably need to use broadcom.ko for PHY connected to interface
> of bgmac supported device so I started looking at it willing to
> understand it better.
> 
> I found AUXCTL part of the driver / lib a bit confusing and hard to read
> so I'm trying to clean it up a bit. I hope this patchset makes following
> AUXCTL operations much easier making it clear which defines are for
> registers and which for values.
> 
> There is no functional change in this pachset.

Series applied, thanks.
