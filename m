From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lpc_eth: Remove unused 'pldat' variable
Date: Mon, 04 Jul 2016 23:56:30 -0700 (PDT)
Message-ID: <20160704.235630.1022481947168523107.davem@davemloft.net>
References: <1467638001-7183-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, netdev@vger.kernel.org
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932837AbcGEG4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 02:56:32 -0400
In-Reply-To: <1467638001-7183-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Mon,  4 Jul 2016 10:13:21 -0300

> Since commit f786f3564c4f02d5026 ("net: ethernet: lpc_eth: use phydev
> from struct net_device") the 'pldat' variable became unused, so
> just remove it.
> 
> Reported-by: Olof's autobuilder <build@lixom.net>
> Signed-off-by: Fabio Estevam <festevam@gmail.com>

Applied.
