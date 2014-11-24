From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: add tipc_netlink.h to uapi Kbuild
Date: Mon, 24 Nov 2014 16:25:33 -0500 (EST)
Message-ID: <20141124.162533.281393904431633682.davem@davemloft.net>
References: <1416835494-7655-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaKXVZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:25:35 -0500
In-Reply-To: <1416835494-7655-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Mon, 24 Nov 2014 14:24:54 +0100

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> tipc_netlink.h is the user-space header for the new netlink api. It
> was accidentally left out of the uapi Kbuild list when the api was
> added.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>

Applied, thanks.
