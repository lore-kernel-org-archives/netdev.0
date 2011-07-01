From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: am79c961a: Omit check for multicast bit
 in netdev_for_each_mc_addr
Date: Thu, 30 Jun 2011 23:56:47 -0700 (PDT)
Message-ID: <20110630.235647.1768047465126096152.davem@davemloft.net>
References: <1309349686-1506-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755049Ab1GAG7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:59:06 -0400
In-Reply-To: <1309349686-1506-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed, 29 Jun 2011 14:14:46 +0200

> There is no need to check for the address being a multicast address in
> the netdev_for_each_mc_addr loop, so remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
