From: Pavel Machek <pavel@ucw.cz>
Subject: size of git repository (was Re: [BUG] New Kernel Bugs)
Date: Sun, 18 Nov 2007 12:44:05 +0000
Message-ID: <20071118124404.GA4037@ucw.cz>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Mark Lord <liml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:1552 "EHLO spitz.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751579AbXKRMoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Nov 2007 07:44:15 -0500
Content-Disposition: inline
In-Reply-To: <4739E3D0.10201@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 2007-11-13 12:50:08, Mark Lord wrote:
> Ingo Molnar wrote:
> >
> >for example git-bisect was godsent. I remember that 
> >years ago bisection of a bug was a very laborous task 
> >so that it was only used as a final, last-ditch 
> >approach for really nasty bugs. Today we can 
> >autonomouly bisect build bugs via a simple shell 
> >command around "git-bisect run", without any human 
> >interaction! This freed up testing resources 
> ..
> 
> It's only a godsend for the few people who happen to be 
> kernel developers
> and who happen to already use git.
> 
> It's a 540MByte download over a slow link for everyone 
> else.

Hmmm, clean-cg is 7.7G on my machine, and yes I tried
git-prune-packed. What am I doing wrong?
						Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
