From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: dsa: mv88e6xxx: Implement Clause 45
 access to SMI devices
Date: Tue, 07 Feb 2017 10:47:29 -0500 (EST)
Message-ID: <20170207.104729.1346331564653985554.davem@davemloft.net>
References: <1486235544-11640-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49416 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932172AbdBGPrc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 10:47:32 -0500
In-Reply-To: <1486235544-11640-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat,  4 Feb 2017 20:12:24 +0100

> The mv88e6390 MDIO bus controllers can support for clause 45 accesses.
> The internal SERDES interfaces need this, and it is likely external
> 10GHz PHYs will be clause 45.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> v2:
> Reworded the commit message a bit, and rebased onto latest net-next.
> No comments, and no reviewed-by tags we received on the first posting.

Applied.
