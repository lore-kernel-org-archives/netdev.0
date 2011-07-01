From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ucc_geth: Omit check for multicast bit
 in netdev_for_each_mc_addr
Date: Thu, 30 Jun 2011 23:57:38 -0700 (PDT)
Message-ID: <20110630.235738.1921750709257462142.davem@davemloft.net>
References: <1309349793-1864-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755067Ab1GAG7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:59:49 -0400
In-Reply-To: <1309349793-1864-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed, 29 Jun 2011 14:16:33 +0200

> There is no need to check for the address being a multicast address in
> the netdev_for_each_mc_addr loop, so remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
