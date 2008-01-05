From: "Manfred Schwarb" <manfred99@gmx.ch>
Subject: Re: driver for et131x?
Date: Sun, 06 Jan 2008 00:50:56 +0100
Message-ID: <20080105235056.170200@gmx.net>
References: <20080104100253.63070@gmx.net>
 <20080105085823.GA19656@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dadams1969@gmail.com, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:53068 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752762AbYAEXu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 18:50:58 -0500
In-Reply-To: <20080105085823.GA19656@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph,

> On Fri, Jan 04, 2008 at 11:02:53AM +0100, Manfred Schwarb wrote:
> > meanwhile the Agere et1310 chip has grown to a quite popular network
> > chip, in laptops as well as for PCI-E cards. The release date of this
> chip was
> > already in June 2004, and still no support in mainline linux.
> > 
> > There is apparently an opensource driver from Agere which is maintained
> by
> > volunteers at http://sourceforge.net/projects/et131x/
> > 
> > It seems some distros (e.g. Ubuntu) even patch their kernels with this
> driver.
> > 
> > Please consider adding support for this chip in mainline linux.
> 
> The driver on the above site would need quite a bit of work to bring it
> up to Linux standards.  That work shouldn't be difficult but enough to
> keep someone busy for a while.  If you have the hardware I'd be happy yo
> guide you through the required work.  Are you interested in taking up
> this project?

I'm afraid my c and linux network driver programming knowledge is not
good enough to dare to take up such a project.

However, I would volunteer to do the dirty work, i.e. bring it to 
linux coding style, try to clean up some #ifdef and typedef things,
if there is someone to take it over afterwards, who will do the
"real" work.

Regards,
Manfred

-- 
GMX FreeMail: 1 GB Postfach, 5 E-Mail-Adressen, 10 Free SMS.
Alle Infos und kostenlose Anmeldung: http://www.gmx.net/de/go/freemail
