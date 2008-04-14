From: David Miller <davem@davemloft.net>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 15:01:05 -0700 (PDT)
Message-ID: <20080414.150105.101568769.davem@davemloft.net>
References: <20080413232441.e216a02c.akpm@linux-foundation.org>
	<20080414072328.GW9785@ZenIV.linux.org.uk>
	<Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, akpm@linux-foundation.org, w@1wt.eu,
	david@lang.hm, sclark46@earthlink.net, johnpol@2ka.mipt.ru,
	rjw@sisk.pl, tilman@imap.cc, Valdis.Kletnieks@vt.edu, lkml@rtr.ca,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, git@vger.kernel.org,
	netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760177AbYDNWBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 18:01:04 -0400
In-Reply-To: <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Morris <jmorris@namei.org>
Date: Tue, 15 Apr 2008 01:54:00 +1000 (EST)

> - Things like "who made the kernel" statistics and related articles ignore 
>   code review.

Note the apparent irony in that the person who ends up often on the
top of those lists, Al Viro, is also someone who also does a
significant amount of code review.

I think this is no accident.
