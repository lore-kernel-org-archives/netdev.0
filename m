From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: Do not iterate over all interfaces
 when finding source address on specific interface.
Date: Fri, 10 Jul 2015 23:19:43 -0700 (PDT)
Message-ID: <20150710.231943.1262522002810525503.davem@davemloft.net>
References: <559F7B27.6030205@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ek@google.com, hannes@stressinduktion.org,
	lorenzo@google.com
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbbGKGTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:19:44 -0400
In-Reply-To: <559F7B27.6030205@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki/吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
Date: Fri, 10 Jul 2015 16:58:31 +0900

> If outgoing interface is specified and the candidate address is
> restricted to the outgoing interface, it is enough to iterate
> over that given interface only.
> 
> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> Acked-by: Erik Kline <ek@google.com>

Applied, thanks!
