From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] bc47xx : export ssb_watchdog_timer_set
Date: Tue, 19 May 2009 18:09:57 +0100
Message-ID: <20090519170957.GA23711@linux-mips.org>
References: <4A11DCBF.9000700@free.fr> <20090518224128.GA11912@tuxdriver.com> <200905191524.20421.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	matthieu castet <castet.matthieu@free.fr>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:55245 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbZESRKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 13:10:40 -0400
Content-Disposition: inline
In-Reply-To: <200905191524.20421.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 03:24:20PM +0200, Michael Buesch wrote:

> > What is the merge path for ssb nowadays?  I used to take these patches
> > (and I'm still happy to do so), but maybe Ralf is (or should be)
> > taking them now?
> 
> That depends on his speed. Last time I submitted a patch through his path,
> it bitrotted for several months before it finally hit mainline.

Maybe because I felt drivers/ssb/ was outside my jurisdiction - and unlike
what alot of people may seem to think I'm not a full time MIPS kernel
hacker.

I can deal with SSB patch if you so desire - but I have no experience with
SSB, so I'd have somebody to rubberstamp non-trivial SSB patches before I
queue them up.  I can keep them either in the usual MIPS trees on
linux-mips.org or I could create a separate linux-ssb tree, depending on
what seems to be sensible.  Also, reading the entry in the maintainers
file I wonder if netdev is really the list of a choice?

  Ralf
