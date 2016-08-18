From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: phy: Sort Makefile and Kconfig
Date: Thu, 18 Aug 2016 15:34:08 -0700
Message-ID: <9988272b-f536-56be-5936-f2c5816efce2@gmail.com>
References: <1471557366-21672-1-git-send-email-andrew@lunn.ch>
 <1471557366-21672-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32975 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754332AbcHSClc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:41:32 -0400
Received: by mail-pa0-f66.google.com with SMTP id vy10so2673975pac.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:41:31 -0700 (PDT)
In-Reply-To: <1471557366-21672-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2016 02:56 PM, Andrew Lunn wrote:
> Sort the files to reduce merge conflicts and to make it easier to find
> drivers by name. Also separate the MDIO bus drivers from the PHY
> drivers, again to help find what you need.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/phy/Kconfig  | 427 ++++++++++++++++++++++++-----------------------
>  drivers/net/phy/Makefile |  76 +++++----
>  2 files changed, 253 insertions(+), 250 deletions(-)

I trust the diffstat which looks stable here, thanks for doing this!

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
