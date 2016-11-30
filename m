From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: brocade: bna: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 30 Nov 2016 10:29:18 -0500 (EST)
Message-ID: <20161130.102918.744635423581846899.davem@davemloft.net>
References: <1480373539-3257-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rasesh.mody@cavium.com, sudarsana.kalluru@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756551AbcK3P3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:29:24 -0500
In-Reply-To: <1480373539-3257-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 28 Nov 2016 23:52:19 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
