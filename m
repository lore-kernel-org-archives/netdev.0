From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 16:38:55 -0400 (EDT)
Message-ID: <20130416.163855.1844059807803447299.davem@davemloft.net>
References: <1366136266-3324-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965164Ab3DPUi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:38:58 -0400
In-Reply-To: <1366136266-3324-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Tue, 16 Apr 2013 15:17:46 -0300

> Using SIMPLE_DEV_PM_OPS can make the code smaller and simpler.
> 
> Also change CONFIG_PM to CONFIG_PM_SLEEP.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
