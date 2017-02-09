From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next 2/2] net: dsa: mv88e6xxx: Add mv88e6390
 watchdog interrupt support
Date: Thu, 9 Feb 2017 17:28:51 +0100
Message-ID: <20170209162851.GD29882@lunn.ch>
References: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
 <1486595023-28371-3-git-send-email-andrew@lunn.ch>
 <87a89v4b9s.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32999 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751235AbdBIQ24 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 11:28:56 -0500
Content-Disposition: inline
In-Reply-To: <87a89v4b9s.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien

>     /* Offset 0x1B: Watch Dog Control Register */
> 
>     int mv88e6097_g2_watchdog_read(...)
>     int mv88e6097_g2_watchdog_enable(...)
>     int mv88e6097_g2_watchdog_disable(...)
>     int mv88e6390_g2_watchdog_read(...)
>     int mv88e6390_g2_watchdog_enable(...)
>     int mv88e6390_g2_watchdog_disable(...)

O.K. Please take a look at my code, and give a detailed description of
what you expect these to do.

     Andrew
