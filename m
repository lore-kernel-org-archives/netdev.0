From: David Miller <davem@davemloft.net>
Subject: Re: cafe8df8b9bc clashes with DSA
Date: Fri, 10 Feb 2017 13:13:37 -0500 (EST)
Message-ID: <20170210.131337.1437636408832249708.davem@davemloft.net>
References: <77093903.194093.1486748785802.JavaMail.zimbra@savoirfairelinux.com>
        <ccabc2d3-9589-f4f5-cdab-ee3ba40e8bc7@gmail.com>
        <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, maowenan@huawei.com, netdev@vger.kernel.org,
        andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbdBJSU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:20:58 -0500
In-Reply-To: <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 10 Feb 2017 12:55:44 -0500

> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> Fixed in the "net" tree with:
>>
>> 6d9f66ac7fec2a6ccd649e5909806dfe36f1fc25 ("net: phy: Fix PHY module
>> checks and NULL deref in phy_attach_direct()"), applies fine to net-next
>> as well.
> 
> Correct, this fixes my setup. Shouldn't this be submitted to net-next as
> well then?

It will propagate there the next time I merge to Linus and then merge
net into net-next.
