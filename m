From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipx: implement shutdown()
Date: Wed, 12 Feb 2014 19:26:54 -0500 (EST)
Message-ID: <20140212.192654.429559794659508939.davem@davemloft.net>
References: <1391901818-13338-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org, 00cpxxx@gmail.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbaBMA0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:26:55 -0500
In-Reply-To: <1391901818-13338-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Sun,  9 Feb 2014 00:23:38 +0100

> IPX doesn't implement shutdown, which poses a problem to some users:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=67841
> 
> This patch is heavily based on the shutdown implementation for unix
> sockets.
> 
> Reported-by: Bruno Jesus <00cpxxx@gmail.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> v2, without debug messages

Applied to net-next, thanks.
