From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] be2net: Rework PCIe error report log messaging
Date: Sat, 19 Oct 2013 19:13:45 -0400 (EDT)
Message-ID: <20131019.191345.743619937500710533.davem@davemloft.net>
References: <20131018210624.GA3944@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3JSXNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 19:13:47 -0400
In-Reply-To: <20131018210624.GA3944@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Fri, 18 Oct 2013 16:06:24 -0500

> Currently we log a message whenever pcie_enable_error_reporting fails.
> The message clutters up logs, especially when we don't support it for VFs.
> Instead enable this only for PFs and log a message when the call succeeds.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied, thanks.
