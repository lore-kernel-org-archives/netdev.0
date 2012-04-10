From: David Miller <davem@davemloft.net>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 09:43:01 -0400 (EDT)
Message-ID: <20120410.094301.415649892550737376.davem@davemloft.net>
References: <4F83F166.4010208@monstr.eu>
	<1334057529.3126.90.camel@edumazet-glaptop>
	<4F841BB9.2030209@monstr.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	john.williams@petalogix.com
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021Ab2DJNnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 09:43:05 -0400
In-Reply-To: <4F841BB9.2030209@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <monstr@monstr.eu>
Date: Tue, 10 Apr 2012 13:38:33 +0200

> There is long history for ll_temac and axi emac drivers. and if you
> compare
> them they are very similar with similar bugs.
> In our distribution we are using older ll_temac driver where this is
> fixed.
> Performance is much higher if you allocate buffers for actual mtu.

You place an enormous burdon upon us when you ask us to analyze your
performance problems and bugs when using out of tree drivers.  Please
do not do this.
