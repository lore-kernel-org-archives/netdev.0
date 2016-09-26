From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: take into account register shift
Date: Sun, 25 Sep 2016 23:46:20 -0400 (EDT)
Message-ID: <20160925.234620.1395322628916558014.davem@davemloft.net>
References: <1474837245-32512-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941394AbcIZDqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 23:46:24 -0400
In-Reply-To: <1474837245-32512-1-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Sun, 25 Sep 2016 23:00:45 +0200

> This aligns smc91x with its cousin, namely smc911x.c.
> This also allows the driver to run also in a device-tree based lubbock
> board build, on which it was tested.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>

Applied to net-next, thanks.
