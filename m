From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 3/3] net: bgmac: use PHY subsystem for initializing
 PHY
Date: Tue, 31 Jan 2017 13:14:52 -0500 (EST)
Message-ID: <20170131.131452.553487511329277271.davem@davemloft.net>
References: <20170128210832.26174-4-zajec5@gmail.com>
        <20170131.130429.1477789092223900995.davem@davemloft.net>
        <1daad20f-f794-3c10-d020-fa08dbf228c2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, jon.mason@broadcom.com, nbd@openwrt.org,
        netdev@vger.kernel.org, rafal@milecki.pl
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40740 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdAaSZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:25:51 -0500
In-Reply-To: <1daad20f-f794-3c10-d020-fa08dbf228c2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 31 Jan 2017 10:06:34 -0800

> On 01/31/2017 10:04 AM, David Miller wrote:
>> 
>> This entire series is being held up because there is still questions about
>> whether this is programming the internal PHYs and therefore whether the
>> code should be placed elsewhere.
>> 
>> Can we please move the discussion forward?
> 
> The patches are good as-is, we can resolve the PHY programming later on
> when we have figured out the details of the 4749 chip we derailed on.

Ok great, series applied, thanks.
