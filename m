From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: dsa: mv88e6xxx: Move forward
 declaration to where it is needed
Date: Thu, 09 Feb 2017 17:11:55 -0500 (EST)
Message-ID: <20170209.171155.1118932102524783959.davem@davemloft.net>
References: <1486594843-28077-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751071AbdBIXGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 18:06:17 -0500
In-Reply-To: <1486594843-28077-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu,  9 Feb 2017 00:00:43 +0100

> Move it out from the middle for the #defines to just before it is
> needed.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks for respinning.
