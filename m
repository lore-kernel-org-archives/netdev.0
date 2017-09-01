From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] net: mdio-mux: Misc fix
Date: Fri, 01 Sep 2017 10:26:51 -0700 (PDT)
Message-ID: <20170901.102651.1703388949595548986.davem@davemloft.net>
References: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdIAR0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:26:53 -0400
In-Reply-To: <20170901115604.27513-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Fri,  1 Sep 2017 13:55:59 +0200

> This patch series fix minor problems found when working on the
> dwmac-sun8i syscon mdio-mux.
 ...
> Changes since v1:
> - Removed obsolete comment about of_mdio_find_bus/put_device
> - removed more DRV_VERSION

Series applied to net-next.
