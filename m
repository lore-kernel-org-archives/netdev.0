From: Pavel Roskin <proski@gnu.org>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Sun, 14 Jan 2007 09:18:12 -0500
Message-ID: <20070114091812.hz2fokosw0o0cc0k@webmail.spamcop.net>
References: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
	<200701132051.52559.mb@bu3sch.de>
	<20070113211030.11zo8cokcsoskccg@webmail.spamcop.net>
	<200701141115.43799.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.cesmail.net ([216.154.195.36]:60030 "HELO
	mailgate.cesmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750896AbXANOSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jan 2007 09:18:13 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701141115.43799.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Michael Buesch <mb@bu3sch.de>:

> Already done. Please pull my tree and check if it still crashes.

The crash is gone!  Thanks!  Still no association though.

> > Actually, I could scan, and I got 7 access points around.  Only one is in
> my
> > apartment.
>
> RX sensitivity is not quite as bad.

I see, the problem must be on the tx side then.

> Well, I don't really know what to do all about this.
> It's strange. I have people reporting that exactly the same cards work
> and people reporting that exactly the same cards don't work over and
> over again.
> So, well. What to do? :)

I'll check in with a HostAP based AP and a separate sniffer, so I can see what's
on the air and what the AP sees.

--
Regards,
Pavel Roskin
