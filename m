From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mvpp2: enable basic 10G support
Date: Tue, 13 Jun 2017 13:00:10 -0400 (EDT)
Message-ID: <20170613.130010.1421332287580540368.davem@davemloft.net>
References: <20170612140139.31377-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        stefanc@marvell.com, mw@semihalf.com, linux@armlinux.org.uk,
        netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751989AbdFMRAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:00:12 -0400
In-Reply-To: <20170612140139.31377-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Mon, 12 Jun 2017 16:01:39 +0200

> On GOP port 0 two MAC modes are available: GMAC and XLG. The XLG MAC is
> used for 10G connectivity. This patch adds a basic 10G support by
> allowing to use the XLG MAC on port 0 and by reworking the
> port_enable/disable functions so that the XLG MAC is configured when
> using 10G.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Applied.
