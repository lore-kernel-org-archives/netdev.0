From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: add NTF_USE support
Date: Mon, 14 Nov 2011 00:42:33 -0500 (EST)
Message-ID: <20111114.004233.1628237035474001987.davem@davemloft.net>
References: <20111109203008.6bebce8d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab1KNFme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 00:42:34 -0500
In-Reply-To: <20111109203008.6bebce8d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 9 Nov 2011 20:30:08 -0800

> More changes to the recent code to support control of forwarding
> database via netlink.
>    * Support NTF_USE like neighbour table
>    * Validate state bits from application
>    * Only send notifications (and change bits) if new entry is
>      different.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
