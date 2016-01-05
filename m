From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] ppp: add netlink support
Date: Tue, 05 Jan 2016 14:15:34 -0500 (EST)
Message-ID: <20160105.141534.858084676889078948.davem@davemloft.net>
References: <cover.1450900138.git.g.nault@alphalink.fr>
	<20160105181020.GB1259@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbcAETPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 14:15:35 -0500
In-Reply-To: <20160105181020.GB1259@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 5 Jan 2016 19:10:20 +0100

> On Wed, Dec 23, 2015 at 09:04:46PM +0100, Guillaume Nault wrote:
>> This series adds netlink support for creating PPP devices.
>> 
> Any feedback on this series? I can see that it has been marked
> "Deferred" in patchwork, so I'm unsure about what to do with this patch
> set now.
> Should I repost later (e.g. after the end of the merge window)? Are
> there any concern/issues with the series itself? Or should the idea of
> implementing netlink handlers for ppp devices be entirely dropped?

Repost it again later, I want more people to see and review this
series and the holidays is not a good time for that...
