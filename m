From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Refactor remaining port
 setup
Date: Tue, 07 Feb 2017 10:48:22 -0500 (EST)
Message-ID: <20170207.104822.524474503892090149.davem@davemloft.net>
References: <1486235728-11775-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49432 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754199AbdBGPsY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 10:48:24 -0500
In-Reply-To: <1486235728-11775-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat,  4 Feb 2017 20:15:28 +0100

> Move the remaining port configuration code which varies per device
> into port.c, using ops were necessary. This makes
> mv88e6xxx_6185_family() and mv88e6xxx_6095_family() unused, so remove
> them.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
