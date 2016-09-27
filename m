From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tg3: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 26 Sep 2016 20:17:33 -0400 (EDT)
Message-ID: <20160926.201733.2276112302187319503.davem@davemloft.net>
References: <1474839084-10883-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: siva.kallam@broadcom.com, prashant@broadcom.com,
        mchan@broadcom.com, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753844AbcI0ARk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 20:17:40 -0400
In-Reply-To: <1474839084-10883-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 25 Sep 2016 23:31:24 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied, thanks.
