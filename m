From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] arc_emac: promiscuous/multicast mode and netpoll
 support
Date: Tue, 13 May 2014 18:03:12 -0400 (EDT)
Message-ID: <20140513.180312.1821582378137845014.davem@davemloft.net>
References: <1399824708-2497-1-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexey.Brodkin@synopsys.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: b.galvani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326AbaEMWDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 18:03:14 -0400
In-Reply-To: <1399824708-2497-1-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Beniamino Galvani <b.galvani@gmail.com>
Date: Sun, 11 May 2014 18:11:46 +0200

> These patches add support for promiscuous mode, multicast filtering
> and netpoll to the ARC EMAC driver.
> 
> They were both tested on a Radxa Rock board which uses a ARC EMAC IP
> core integrated in the Rockchip RK3188 SoC.

Series applied to net-next, thanks.
