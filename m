From: David Miller <davem@davemloft.net>
Subject: Re: arm64 allmodconfig failures in nft_reject_bridge.c
Date: Thu, 13 Nov 2014 15:23:53 -0500 (EST)
Message-ID: <20141113.152353.548265176661091467.davem@davemloft.net>
References: <20141113114357.GA7857@salvia>
	<20141113.143513.785778562781935404.davem@davemloft.net>
	<20141113194752.GQ3815@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, linux@roeck-us.net, kaber@trash.net,
	kadlec@blackhole.kfki.hu, stephen@networkplumber.org,
	linaro-kernel@lists.linaro.org,
	kernel-build-reports@lists.linaro.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933975AbaKMUX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 15:23:58 -0500
In-Reply-To: <20141113194752.GQ3815@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Thu, 13 Nov 2014 19:47:52 +0000

> On Thu, Nov 13, 2014 at 02:35:13PM -0500, David Miller wrote:
> 
>> I hold changes in my tree for a week or more, because I want them to
>> "cook" there before they go to Linus.
> 
> Hrm.  Guess there must've been some other change in -next that pulled
> the header in implicitly here :(

-next pulls in my 'net' tree, so got the fix.
