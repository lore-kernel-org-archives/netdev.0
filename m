From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 00/13] phylink and sfp support
Date: Sun, 06 Aug 2017 21:00:37 -0700 (PDT)
Message-ID: <20170806.210037.1669464786772980509.davem@davemloft.net>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
        <20170806182622.GA31844@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@armlinux.org.uk, f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdHGEAi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:00:38 -0400
In-Reply-To: <20170806182622.GA31844@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 6 Aug 2017 20:26:22 +0200

> On Tue, Jul 25, 2017 at 03:01:39PM +0100, Russell King - ARM Linux wrote:
>> Hi,
>> 
>> This patch series introduces generic support for SFP sockets found on
>> various Marvell based platforms.  The idea here is to provide common
>> SFP socket support which can be re-used by network drivers as
>> appropriate, rather than each network driver having to re-implement
>> SFP socket support.
> 
> Hi Russell
> 
> Please could you repost with all the Reviewed-By added and RFC
> removed. The code should get merged then.

No need, I just merged the series into net-next.

Thanks.
