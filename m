From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fec: add fallback to random MAC address
Date: Fri, 31 May 2013 16:18:39 -0700 (PDT)
Message-ID: <20130531.161839.1051677002623812987.davem@davemloft.net>
References: <1370020942-8342-1-git-send-email-l.stach@pengutronix.de>
	<51A8E481.802@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: l.stach@pengutronix.de, netdev@vger.kernel.org, pavel@denx.de
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757517Ab3EaXSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 19:18:42 -0400
In-Reply-To: <51A8E481.802@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 31 May 2013 21:57:21 +0400

>    eth_hw_addr_random(ndev) might be a bit better -- it classifies
>    the MAC address in 'struct net_device' as random.

Right.
