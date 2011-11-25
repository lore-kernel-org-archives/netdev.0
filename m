From: Domenico Andreoli <cavokz@gmail.com>
Subject: Re: MACH_QQ2440 (and CS890x)
Date: Fri, 25 Nov 2011 10:57:30 +0100
Message-ID: <20111125095730.GA16935@glitch>
References: <1322169455.25125.104.camel@x61.thuisdomein>
 <20111125093651.GA10636@glitch>
 <1322214386.25125.127.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, kernel@pengutronix.de
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39189 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714Ab1KYJ5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 04:57:32 -0500
Received: by bke11 with SMTP id 11so4142013bke.19
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 01:57:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1322214386.25125.127.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2011 at 10:46:26AM +0100, Paul Bolle wrote:
> (Canned message follows.)
> 
> On Fri, 2011-11-25 at 10:36 +0100, Domenico Andreoli wrote:
> > On Thu, Nov 24, 2011 at 10:17:35PM +0100, Paul Bolle wrote:
> > > 3) Are there any plans to add a Kconfig entry for MACH_QQ2440? If not,
> > > should I submit the (trivial) patch to drop that Kconfig symbol and that
> > > preprocessor macro?
> > 
> > The plan for qq2440 is to use the cs890x platform driver which is being
> > developed by Jaccon [0], maybe in the OF variant.  I already asked him
> > to remove these specific and unused macros for me.
> > 
> > So thank you for the offer but I hope the work of Jaccon will be
> > merged soon.
> 
> Thanks. I'll stop worrying about this invalid Kconfig dependency for
> now. It might pop up again if I ever decide to scan the mainline tree
> for invalid symbols again. We'll see.

In such case I already ack the commit.

> Paul Bolle
Domenico
