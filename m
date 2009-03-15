From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Sun, 15 Mar 2009 21:26:03 +0100
Message-ID: <20090315202603.GA9077@elte.hu>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera> <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com> <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com> <1237140665.24621.2.camel@johannes.local> <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain> <1237143683.24621.7.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40195 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758147AbZCOU2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 16:28:32 -0400
Content-Disposition: inline
In-Reply-To: <1237143683.24621.7.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Johannes Berg <johannes@sipsolutions.net> wrote:

> On Sun, 2009-03-15 at 11:44 -0700, Linus Torvalds wrote:
> 
> > Johannes - "not believable" is simply not an argument. If 
> > Jeff can show a difference, then your disbelief is totally 
> > irrelevant, and clearly shows that you are basing your 
> > beliefs on incorrect assumptions (like some specific version 
> > of firmware that isn't the whole story).
> 
> Linus, Jeff is totally unbelievable here -- I just realised 
> that the commit he quotes doesn't even change the driver he's 
> working with.

Even if so (bisection is very hard and error-prone) why do you 
shape your reaction to it as a personal attack? Why do you say 
"Jeff is totally unbelievable" - why dont you say something more 
amicable like:

 " Hm, that's weird - that commit does not even seem to affect 
   the driver you are working with. Could you please re-check 
   the final bits of the bisection to make sure you got the 
   right commit ID? "

Instead of this irritated-sounding attack tone you are using. 
It's not helpful. Testers are there to help you, not to annoy 
you. If they annoy you then you are in the wrong business.

	Ingo
