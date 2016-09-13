From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: apm: xgene: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 13 Sep 2016 11:46:00 -0400 (EDT)
Message-ID: <20160913.114600.864935272090037916.davem@davemloft.net>
References: <1473609244-4365-1-git-send-email-tremyfr@gmail.com>
        <1473609244-4365-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758240AbcIMPqB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:46:01 -0400
In-Reply-To: <1473609244-4365-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 11 Sep 2016 17:54:04 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
