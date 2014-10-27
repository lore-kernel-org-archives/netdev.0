From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] ipx: remove unnecessary casting on ntohl
Date: Mon, 27 Oct 2014 16:04:49 -0400 (EDT)
Message-ID: <20141027.160449.423435641618403620.davem@davemloft.net>
References: <1414439709-5870-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, joe@perches.com,
	acme@ghostprotocols.net, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbaJ0UEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 16:04:52 -0400
In-Reply-To: <1414439709-5870-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 27 Oct 2014 20:55:08 +0100

> use %08X instead of %08lX and remove casting.
> 
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> V2: remove casting instead of long unsigned int -> unsigned long
> (suggested by Joe Perches)

Applied.
