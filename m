From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add tcp_syncookies mode to allow
 unconditionally generation of syncookies
Date: Tue, 30 Jul 2013 16:18:02 -0700 (PDT)
Message-ID: <20130730.161802.528934142494009234.davem@davemloft.net>
References: <20130726154323.GA12067@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, fw@strlen.de
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758221Ab3G3XSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:18:02 -0400
In-Reply-To: <20130726154323.GA12067@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 26 Jul 2013 17:43:23 +0200

> From the documentation update:
> | If you want to test which effects syncookies have to your
> | network connections you can set this knob to 2 to enable
> | unconditionally generation of syncookies.
> 
> Original idea and first implementation by Eric Dumazet.
> 
> Cc: Florian Westphal <fw@strlen.de>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
