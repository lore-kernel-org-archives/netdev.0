From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] ipv6: sysctl to restrict candidate source
 addresses
Date: Wed, 22 Jul 2015 10:54:20 -0700 (PDT)
Message-ID: <20150722.105420.1041491659305096310.davem@davemloft.net>
References: <1437550705-10508-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, hannes@stressinduktion.org,
	lorenzo@google.com, netdev@vger.kernel.org
To: ek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443AbbGVRyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 13:54:21 -0400
In-Reply-To: <1437550705-10508-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Kline <ek@google.com>
Date: Wed, 22 Jul 2015 16:38:25 +0900

> Per RFC 6724, section 4, "Candidate Source Addresses":
> 
>     It is RECOMMENDED that the candidate source addresses be the set
>     of unicast addresses assigned to the interface that will be used
>     to send to the destination (the "outgoing" interface).
> 
> Add a sysctl to enable this behaviour.
> 
> Signed-off-by: Erik Kline <ek@google.com>

Applied, thanks.
