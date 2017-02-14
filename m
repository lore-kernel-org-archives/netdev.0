From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net:dsa:mv88e6xxx: use watchdog ops for 6097
 chip
Date: Tue, 14 Feb 2017 11:45:47 -0500 (EST)
Message-ID: <20170214.114547.2093955277173858665.davem@davemloft.net>
References: <1487068170-18923-1-git-send-email-volodymyr.bendiuga@gmail.com>
        <20170214154618.GB15553@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: volodymyr.bendiuga@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753866AbdBNQpy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 11:45:54 -0500
In-Reply-To: <20170214154618.GB15553@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 14 Feb 2017 16:46:18 +0100

> On Tue, Feb 14, 2017 at 11:29:30AM +0100, Volodymyr Bendiuga wrote:
>> mv88e6097 chip requires watchdog_ops to be set.
> 
> Hi Volodymyr
> 
> Upps. Thanks for the fix.
>  
>> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied.
