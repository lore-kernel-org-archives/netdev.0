From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Fri, 06 Dec 2013 12:15:23 -0500 (EST)
Message-ID: <20131206.121523.75881126286614298.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com>
	<52A1A099.3010901@redhat.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7469@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, eric.dumazet@gmail.com, sekletar.m@gmail.com,
	msekleta@redhat.com, netdev@vger.kernel.org, mtk.manpages@gmail.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755228Ab3LFRPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:15:25 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7469@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Fri, 6 Dec 2013 11:15:58 -0000

>>   i) Does BSD have such extensions and if so do we overlap some?
>> 
>> ii) Is it planned to also introduce SO_BPF_EXTENSIONS for BSD kernels
>>      to have one common api (that i.e. libpcap would then make use of)?
> 
> If it is useful to add any of the extensions, and they don't collide
> with any other existing changes, then they might be added.
> Adding a request that indicates which extensions are supported should
> be easier than adding the extensions themselves.
> Adding all the Linux extensions at once could be problematic.

Again, we're not going to accomodate this, sorry.
