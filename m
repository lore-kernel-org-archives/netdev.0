From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add CDC-ACM support for the CX93010-2x UCMxx USB Modem
Date: Thu, 11 Oct 2012 15:20:30 -0400 (EDT)
Message-ID: <20121011.152030.1152791142314922132.davem@davemloft.net>
References: <1349909342-13379-1-git-send-email-jc@eclis.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.de
To: jc@eclis.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756163Ab2JKTUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 15:20:32 -0400
In-Reply-To: <1349909342-13379-1-git-send-email-jc@eclis.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Christian de Rivaz <jc@eclis.ch>
Date: Thu, 11 Oct 2012 00:49:02 +0200

> This USB V.92/V.32bis Controllered Modem have the USB vendor ID 0x0572
> and device ID 0x1340. It need the NO_UNION_NORMAL quirk to be recognized.
> 
> Reference:
> http://www.conexant.com/servlets/DownloadServlet/DSH-201723-005.pdf?docid=1725&revid=5
> See idVendor and idProduct in table 6-1. Device Descriptors
> 
> Signed-off-by: Jean-Christian de Rivaz <jc@eclis.ch>

Applied.
