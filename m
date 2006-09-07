From: Pavel Machek <pavel@suse.cz>
Subject: Re: [patch 37/37] sky2: version 1.6.1
Date: Thu, 7 Sep 2006 23:03:46 +0200
Message-ID: <20060907210346.GF29890@elf.ucw.cz>
References: <20060906224631.999046890@quad.kroah.org> <20060906225812.GL15922@kroah.com> <20060907192528.GG8793@ucw.cz> <20060907203426.GB556@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, stable@kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:6595 "EHLO amd.ucw.cz")
	by vger.kernel.org with ESMTP id S932182AbWIGVEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2006 17:04:05 -0400
To: Greg KH <gregkh@suse.de>
Content-Disposition: inline
In-Reply-To: <20060907203426.GB556@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > > -stable review patch.  If anyone has any objections, please let us know.
> > > 
> > > ------------------
> > > From: Stephen Hemminger <shemminger@osdl.org>
> > > 
> > > Since this code incorporates some of the fixes from 2.6.18, change
> > > the version number.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > > Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> > 
> > Not sure, one of 'stable' criteria is 'fixes bad bug'. What bug does
> > this fix?
> 
> The previous 5 patches changed this driver, so changing the version
> number of it is acceptable to me.

Well... I agree that version change is understandable, but it will be
also surprising for the users, and stable rules were quite strict with
"must fix obvious bug"...
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
