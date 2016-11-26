From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] Add support for the MV88e6097
Date: Fri, 25 Nov 2016 19:54:23 -0500 (EST)
Message-ID: <20161125.195423.2195982423664318118.davem@davemloft.net>
References: <20161123205952.6231-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, stefan.eichenberger@netmodule.com
To: eichest@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751613AbcKZAy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:54:28 -0500
In-Reply-To: <20161123205952.6231-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Eichenberger <eichest@gmail.com>
Date: Wed, 23 Nov 2016 21:59:50 +0100

> This patchset will add support for the MV88E6097 DSA switch and enable
> EDSA on MV88E6097 family devices.
> 
> Changes since v1:
> - Add missing g1_irqs = 8
> - Add missing comment after mv88e6097_ops
> - Change patch order

This doesn't apply cleanly to net-next, please respin.

Thanks.
