From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET_VENDOR_TI: make available for am33xx as well
Date: Wed, 24 Oct 2012 23:07:52 -0400 (EDT)
Message-ID: <20121024.230752.2101476499417089439.davem@davemloft.net>
References: <1351030315-4156-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59906 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756140Ab2JYDHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 23:07:53 -0400
In-Reply-To: <1351030315-4156-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Wed, 24 Oct 2012 00:11:55 +0200

> The cpsw/davinci mdio ip cores are present on am33xx, so make NET_VENDOR_TI
> visible for it as well.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied, thanks.
