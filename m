From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: macb: Remove obsolete comment from Kconfig
Date: Tue, 09 Dec 2014 15:39:59 -0500 (EST)
Message-ID: <20141209.153959.1309797002608875733.davem@davemloft.net>
References: <1417784633-13360-1-git-send-email-james.byrne@origamienergy.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: james.byrne@origamienergy.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbaLIUkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:40:01 -0500
In-Reply-To: <1417784633-13360-1-git-send-email-james.byrne@origamienergy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Byrne <james.byrne@origamienergy.com>
Date: Fri,  5 Dec 2014 13:03:53 +0000

> The Kconfig file says that Gigabit mode is not supported, but it has been
> supported since commit 140b7552fdff04bbceeb842f0e04f0b4015fe97b ("net/macb:
> Add support for Gigabit Ethernet mode").
> 
> Signed-off-by: James Byrne <james.byrne@origamienergy.com>

Applied to net-next, thanks.
