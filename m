From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/5] net: dsa: mv88e6xxx: Add basic SERDES
 support
Date: Fri, 26 May 2017 15:01:05 -0400 (EDT)
Message-ID: <20170526.150105.549634794573509206.davem@davemloft.net>
References: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbdEZTBH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 15:01:07 -0400
In-Reply-To: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 26 May 2017 01:03:19 +0200

> Some of the Marvell switches are SERDES interface, which must be
> powered up before packets can be passed. This is particularly true on
> the 6390, where the SERDES defaults to down, probably to save power.
> 
> This series refactors the existing SERDES support for the 6352, and
> adds 6390 support.
 ...

Series applied, thanks Andrew.
