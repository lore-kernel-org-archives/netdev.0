From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Fri, 19 Apr 2013 16:38:31 -0400 (EDT)
Message-ID: <20130419.163831.1434224426107133131.davem@davemloft.net>
References: <20130419.155859.1092595631804890737.davem@davemloft.net>
	<20130419131632.31fce894@nehalam.linuxnetplumber.net>
	<1366403483.16391.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777Ab3DSUid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:38:33 -0400
In-Reply-To: <1366403483.16391.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Apr 2013 13:31:23 -0700

> On Fri, 2013-04-19 at 13:16 -0700, Stephen Hemminger wrote:
> 
>> I can not get line rate output with pktgen on existing kernels today.
> 
> I have no trouble saturating at line rate with pktgen, and using
> multiqueue NIC.

+1

> I really hope we do not use pktgen as an argument for having netmap in
> the kernel.

Me too.
