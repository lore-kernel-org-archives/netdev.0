From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] fec: Simplify the PM related hooks
Date: Thu, 24 Jul 2014 23:26:32 -0700 (PDT)
Message-ID: <20140724.232632.530820952427153872.davem@davemloft.net>
References: <1406237041-29468-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759264AbaGYG0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:26:34 -0400
In-Reply-To: <1406237041-29468-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Thu, 24 Jul 2014 18:24:01 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Get rid of the CONFIG_PM_SLEEP ifdef by annotating the suspend/resume functions
> with '__maybe_unused' in order to keep the code simpler and shorter.
> 
> While at it, declare the suspend/resume functions in a single line.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
