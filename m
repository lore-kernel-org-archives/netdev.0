From: David Miller <davem@davemloft.net>
Subject: Re: [mISDN PATCH v2 00/19] mISDN patchset for next
Date: Mon, 25 May 2009 00:53:11 -0700 (PDT)
Message-ID: <20090525.005311.249649223.davem@davemloft.net>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	i4ldeveloper@listserv.isdn4linux.de
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752383AbZEYHxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 03:53:12 -0400
In-Reply-To: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <keil@b1-systems.de>
Date: Fri, 22 May 2009 22:42:47 +0200

> This is a update of the mISDN driver for net-next.
> It syncs the mISDN driver with the development on git.misdn.org.
> More updates (new hardware support) will follow.
> 
> You can pull it from 
> git://master.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next.git for_dave
> 
> Andreas Eversberg (12):
>   Add watchdog functionality to hfcmulti driver
>   DSP now uses ring buffer for echo canceler

There is no way I'm pulling from that tree, even with the fixed
up patch #9.

How in the world is anyone supposed to know these are mISDN changes
by looking at those changlog header lines?  They say nothing about
the subsystem they are in.

I've modified every commit log message so that it says:

mISDN: foo bar baz

instead of the anonymous stuff above.
