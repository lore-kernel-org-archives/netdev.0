From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] net: dsa: lan9303: Add fdb/mdb methods
Date: Sun, 22 Oct 2017 02:41:45 +0100 (WEST)
Message-ID: <20171022.024145.2295148491915584487.davem@davemloft.net>
References: <20171020101910.2245-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: privat@egil-hjelmeland.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57302 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932311AbdJVBlt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 21:41:49 -0400
In-Reply-To: <20171020101910.2245-1-privat@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Fri, 20 Oct 2017 12:19:08 +0200

> This series add support for accessing and managing the lan9303 ALR 
> (Address Logic Resolution). 
> 
> The first patch add low level functions for accessing the ALR, along
> with port_fast_age and port_fdb_dump methods.
> 
> The second patch add functions for managing ALR entires, along with
> remaining fdb/mdb methods. 
> 
> Note that to complete STP support, a special ALR entry with the STP eth
> address must be added too. This must be addressed later.

Series applied, thank you.
