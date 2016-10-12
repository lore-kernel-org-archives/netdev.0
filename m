From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 12 Oct 2016 01:41:20 -0400 (EDT)
Message-ID: <20161012.014120.2261415940292360257.davem@davemloft.net>
References: <1475402809-11593-1-git-send-email-tremyfr@gmail.com>
        <1475402809-11593-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752097AbcJLFlY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 01:41:24 -0400
In-Reply-To: <1475402809-11593-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  2 Oct 2016 12:06:49 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
