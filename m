From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Thu, 12 May 2011 18:58:08 -0400 (EDT)
Message-ID: <20110512.185808.1455580083987815119.davem@davemloft.net>
References: <20110507095910.GC30492@uio.no>
	<20110512.155221.59681200.davem@davemloft.net>
	<20110512225458.GA19573@uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, yoshfuji@linux-ipv6.org
To: sgunderson@bigfoot.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756900Ab1ELXA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 19:00:56 -0400
In-Reply-To: <20110512225458.GA19573@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Date: Fri, 13 May 2011 00:54:58 +0200

> On Thu, May 12, 2011 at 03:52:21PM -0700, David Miller wrote:
>>>> I cooked for you the official patch and made sure it worked with a RED
>>>> ECN setup, and one ipv6 tcp xmit.
>>> Great, thanks :-) This looks good to me.
>> Applied, thanks everyone.
> 
> Do you think it would be possible to get it backported to stable kernels?
> (I've been told getting it into the 2.6.32.x series is the easiest way to get
> it into Debian stable, and I guess it should be a candidate.)

I only submit patches for what stable@kernel.org is actively maintaining
which is 2.6.38 right now.
