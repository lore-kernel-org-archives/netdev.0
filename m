From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Only pass pdev in fec_ptp_init()
Date: Fri, 07 Jun 2013 14:41:33 -0700 (PDT)
Message-ID: <20130607.144133.52809964951362586.davem@davemloft.net>
References: <1370638080-19891-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab3FGVle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 17:41:34 -0400
In-Reply-To: <1370638080-19891-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Fri,  7 Jun 2013 17:48:00 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Passing pdev in fec_ptp_init() is enough, since we can get ndev locally.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
