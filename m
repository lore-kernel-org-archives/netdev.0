From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/2] MV88E6390 fixes
Date: Thu, 02 Feb 2017 22:07:02 -0500 (EST)
Message-ID: <20170202.220702.80320186945989587.davem@davemloft.net>
References: <1485992776-23750-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38526 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751867AbdBCDHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:07:03 -0500
In-Reply-To: <1485992776-23750-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu,  2 Feb 2017 00:46:14 +0100

> Two patches, which have been posted before. Fix simple issues in the
> mv88e6390 support. These don't need to go to stable, since the
> mv88e6390 support in stable is insufficient to be usable.
> 
> To apply cleanly, these patches rely on "net: dsa: mv88e6xxx:
> Workaround missing PHY".
> 
> v2: Added Reviewed-by.
>     Removed a redundant "the"

Series applied, thanks Andrew.
