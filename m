From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Use EDSA on mv88e6097
Date: Tue, 06 Dec 2016 10:17:31 -0500 (EST)
Message-ID: <20161206.101731.187894163709917787.davem@davemloft.net>
References: <20161205131242.19370-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, stefan.eichenberger@netmodule.com
To: eichest@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752087AbcLFPSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:18:09 -0500
In-Reply-To: <20161205131242.19370-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Eichenberger <eichest@gmail.com>
Date: Mon,  5 Dec 2016 14:12:42 +0100

> Use DSA_TAG_PROTO_EDSA as tag_protocol for the mv88e6097. The 
> initialisation was missing before.
> 
> Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>

Applied, thanks.
