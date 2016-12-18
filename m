From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cirrus: ep93xx: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 17 Dec 2016 21:32:03 -0500 (EST)
Message-ID: <20161217.213203.2167939677110104332.davem@davemloft.net>
References: <1481581713-6590-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hsweeten@visionengravers.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47512 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759738AbcLRCcF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 21:32:05 -0500
In-Reply-To: <1481581713-6590-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 12 Dec 2016 23:28:33 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
