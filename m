From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Thu, 27 Jan 2011 12:29:45 -0800 (PST)
Message-ID: <20110127.122945.226772078.davem@davemloft.net>
References: <20110126.152538.260074157.davem@davemloft.net>
	<1296122511.3027.11.camel@edumazet-laptop>
	<1296123612.3027.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46490
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501Ab1A0U3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 15:29:10 -0500
In-Reply-To: <1296123612.3027.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Jan 2011 11:20:12 +0100

> Hmm, reading again, I realize the rt->fi was set only when installing
> the readonly metrics, so ignore my previous mail.

Hehe, I was so eager to explain that I replied to it already :-)
