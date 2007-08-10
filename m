From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for 2.6.24] SCTP: Rewrite of sctp buffer management code
Date: Fri, 10 Aug 2007 16:37:59 -0700 (PDT)
Message-ID: <20070810.163759.48396729.davem@davemloft.net>
References: <46BCCE8B.2050605@hp.com>
	<20070810.150625.105430969.davem@davemloft.net>
	<20070810230126.GB3983@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753577AbXHJXh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 19:37:59 -0400
In-Reply-To: <20070810230126.GB3983@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 10 Aug 2007 19:01:26 -0400

> Thanks for applying this Dave, but something seems to have occured during your
> application.  The commitdiff:
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.24.git;a=commitdiff;h=e20e5d698dcccd2e84ee2e1e482b0b203f885c00
> only shows applications to socket.c, while the patch that vlad sent you changed
> much more than that.

Vlad's posted patch only had the socket.c changes, that's the
problem.  I just double checked in the archives on marc.info

I'm reverting this, please sort this out.
