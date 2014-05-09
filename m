From: David Miller <davem@davemloft.net>
Subject: Re: cassini: possible recursive locking detected
Date: Fri, 09 May 2014 16:33:30 -0400 (EDT)
Message-ID: <20140509.163330.1112297139498899531.davem@davemloft.net>
References: <20140508223833.GB4385@lianli>
	<alpine.SOC.1.00.1405090726190.12382@math.ut.ee>
	<20140509090642.GA4267@lianli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, netdev@vger.kernel.org
To: emilgoode@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756972AbaEIUdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:33:32 -0400
In-Reply-To: <20140509090642.GA4267@lianli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Goode <emilgoode@gmail.com>
Date: Fri, 9 May 2014 11:06:42 +0200

> I searched the net a bit and found these old threads:
> 
> http://lists.freebsd.org/pipermail/freebsd-sparc64/2010-January/006935.html
> 
> "FreeBSD currently crashes on older models of V480 when attempting
>  to use an on-board NIC due to what appears to be a CPU bug which
>  needs to be worked around."

I wish I still had a copy of that Schizo chip errata document referenced
at the end of that posting, it's not accessible any longer.
