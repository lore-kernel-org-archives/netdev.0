From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Fri, 27 Feb 2015 20:35:34 -0500 (EST)
Message-ID: <20150227.203534.937629389554126899.davem@davemloft.net>
References: <20150226100235.GA16032@casper.infradead.org>
	<20150227.173011.720468189098021308.davem@davemloft.net>
	<20150228004840.GA18513@acer.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, daniel@iogearbox.net,
	David.Laight@ACULAB.COM, pablo@netfilter.org, johunt@akamai.com,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbB1Bfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 20:35:38 -0500
In-Reply-To: <20150228004840.GA18513@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 28 Feb 2015 00:48:40 +0000

> It seems to me that we have enough use cases right now that problems
> have become quite visible, and until we're sure they're actually
> solvable for all these different use cases I'd advocate for not
> moving more subsystems to use this.

No objections.
