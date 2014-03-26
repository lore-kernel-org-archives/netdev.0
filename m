From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc911x: No need to print driver version
Date: Wed, 26 Mar 2014 15:46:42 -0400 (EDT)
Message-ID: <20140326.154642.43720367552970382.davem@davemloft.net>
References: <1395676646-14178-1-git-send-email-fabio.estevam@freescale.com>
	<1395676646-14178-2-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156AbaCZTqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:46:44 -0400
In-Reply-To: <1395676646-14178-2-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 24 Mar 2014 12:57:26 -0300

> Having the kernel to print:
> 
> "smsc911x: Driver version 2008-10-21" on every boot is not very useful, so
> remove the print of the driver version.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
