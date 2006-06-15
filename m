From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 5/5] bcm43xx-d80211: fix sending of fragments
Date: Thu, 15 Jun 2006 22:35:47 +0200
Message-ID: <200606152235.47320.mb@bu3sch.de>
References: <20060612191606.7AA8E48391@silver.suse.cz> <200606151855.11953.mb@bu3sch.de> <20060615222701.10dddb98@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49040
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750798AbWFOUgV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 16:36:21 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060615222701.10dddb98@logostar.upir.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 June 2006 22:27, Jiri Benc wrote:
> Thu, 15 Jun 2006 18:55:11 +0200, Michael Buesch pise:
> > Please also merge the other patch. It is too hard to figure out
> > the dependencies for me now. So simply merge it and I will submit
> > a fixup patch later, after you pushed it out.
> > The Subject was:
> > [incomplete 2/5] bcm43xx-d80211: per-queue TX flow control
> 
> There is no need to hurry. Let's wait with all my d80211 patches to next
> week so people have enough time to go through them and comment. If there
> are no objections by start of the next week, I will send a pull request.
> 
> Michael, I set up a 'devel' branch in my git repository for you
> (git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git); it's
> without the bcm43xx patch.

Oh, nice. Thanks. I will cook a patch against it.

> I'm going away now and won't be available till Monday.
> 
> > It's not so much of trouble, if we break wireless-dev for one or
> > two days, so this is easiest.
> > Please notify me after you pushed the stuff to public repository,
> > so I can pull and fix it.
> 
> 

-- 
Greetings Michael.
