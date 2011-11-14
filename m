From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESUBMIT2 net-next 1/2] IPv6 routing, NLM_F_* flag
 support: warn if NEWROUTE lacks of both CREATE and REPLACE flags
Date: Mon, 14 Nov 2011 03:36:08 -0500 (EST)
Message-ID: <20111114.033608.2000639077648429389.davem@davemloft.net>
References: <1321254611.23935.15.camel@hakki>
	<20111114.020617.136865443034405914.davem@davemloft.net>
	<1321259480.23935.75.camel@hakki>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab1KNIgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 03:36:17 -0500
In-Reply-To: <1321259480.23935.75.camel@hakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Vaittinen <matti.vaittinen@nsn.com>
Date: Mon, 14 Nov 2011 10:31:20 +0200

> Messages can be changed, that's no problem. I would like to hear suggestions 
> because I personally see not much problems in current messages. 

You don't even say that the route request is for an ipv6 route.

How in the world can we track down the application if you don't
even say what protocol the route request is for?
