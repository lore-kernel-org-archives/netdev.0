From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] packet: Report fanout and rings via diag
Date: Mon, 20 Aug 2012 02:23:25 -0700 (PDT)
Message-ID: <20120820.022325.1399141203373773537.davem@davemloft.net>
References: <502D125A.40701@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab2HTJX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 05:23:26 -0400
In-Reply-To: <502D125A.40701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 16 Aug 2012 19:31:38 +0400

> After this the packet diag module reports everything that can be
> configured on a packet socket via AF_PACKET-specific API.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied to net-next, thanks.
