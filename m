From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net/stable] can bcm: fix incomplete tx_setup fix
Date: Thu, 29 Sep 2011 15:38:44 -0400 (EDT)
Message-ID: <20110929.153844.1309851828877561670.davem@davemloft.net>
References: <4E84C4B9.7020706@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, nautsch@gmail.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755403Ab1I2Tmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 15:42:50 -0400
In-Reply-To: <4E84C4B9.7020706@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Thu, 29 Sep 2011 21:19:21 +0200

> The commit aabdcb0b553b9c9547b1a506b34d55a764745870 ("can bcm: fix tx_setup
> off-by-one errors") fixed only a part of the original problem reported by
> Andre Naujoks. It turned out that the original code needed to be re-ordered
> to reduce complexity and to finally fix the reported frame counting issues.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, thanks.
