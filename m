From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fec: Use devm_request_and_ioremap()
Date: Tue, 12 Mar 2013 08:16:08 -0400 (EDT)
Message-ID: <20130312.081608.1848097055777124163.davem@davemloft.net>
References: <1363023175-17597-1-git-send-email-fabio.estevam@freescale.com>
	<1363023175-17597-2-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203Ab3CLMP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 08:15:56 -0400
In-Reply-To: <1363023175-17597-2-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 11 Mar 2013 14:32:55 -0300

> Using devm_request_and_ioremap() can make the code cleaner and simpler.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
