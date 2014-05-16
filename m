From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: ip_tunnels: disable dst cache for nbma gre
 tunnels
Date: Thu, 15 May 2014 23:29:05 -0400 (EDT)
Message-ID: <20140515.232905.995406666776115109.davem@davemloft.net>
References: <20140424151647.2a917ff1@vostro>
	<1400142917-1849-1-git-send-email-timo.teras@iki.fi>
	<20140515203535.33ad90fd@vostro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbaEPD3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:29:07 -0400
In-Reply-To: <20140515203535.33ad90fd@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Thu, 15 May 2014 20:35:35 +0300

> I meant tunnel->parms.iph.daddr here.  tunnel->daddr does not even
> exist. I wonder which tree I was testing. I'll retry tests and send new
> patch.

Oops, let me know when you have this ready :-/
