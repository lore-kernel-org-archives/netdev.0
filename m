From: Michael Kerrisk <mtk-manpages@gmx.net>
Subject: Re: [PATCH] ip(7) IP_PMTUDISC_PROBE
Date: Sun, 08 Apr 2007 20:08:44 +0200
Message-ID: <46192FAC.4040703@gmx.net>
References: <11746948063923-git-send-email-jheffner@psc.edu> <11746948061847-git-send-email-jheffner@psc.edu> <11746948063971-git-send-email-jheffner@psc.edu> <p73hcs66a8j.fsf@bingen.suse.de> <4609640D.7010709@psc.edu> <20070327193115.GA28138@one.firstfloor.org> <460975F1.60901@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:51061 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751653AbXDHSIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Apr 2007 14:08:49 -0400
In-Reply-To: <460975F1.60901@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Document new IP_PMTUDISC_PROBE value for IP_MTU_DISCOVERY.  (Going into
> > 2.6.22).

Hi John,

Thanks -- accepted -- fix will appear in man-pages-2.47.

Andi: thanks for pointing John in the right direction.

Cheers,

Michael


> > ------------------------------------------------------------------------
> >
> > diff -rU3 man-pages-2.43-a/man7/ip.7 man-pages-2.43-b/man7/ip.7
> > --- man-pages-2.43-a/man7/ip.7	2006-09-26 09:54:29.000000000 -0400
> > +++ man-pages-2.43-b/man7/ip.7	2007-03-27 15:46:18.000000000 -0400

-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7
Want to help with man page maintenance?
Grab the latest tarball at http://www.kernel.org/pub/linux/docs/manpages/
read the HOWTOHELP file and grep the source files for 'FIXME'.
