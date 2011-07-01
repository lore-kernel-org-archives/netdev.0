From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: de4x5: Omit check for multicast bit
 in netdev_for_each_mc_addr
Date: Fri, 01 Jul 2011 01:51:20 -0700 (PDT)
Message-ID: <20110701.015120.358685302882489024.davem@davemloft.net>
References: <1309349760-1776-1-git-send-email-tklauser@distanz.ch>
	<1309505872-28090-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755538Ab1GAIv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 04:51:28 -0400
In-Reply-To: <1309505872-28090-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri,  1 Jul 2011 09:37:52 +0200

> There is no need to check for the address being a multicast address in
> the netdev_for_each_mc_addr loop, so remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
