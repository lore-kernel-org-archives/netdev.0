From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [GIT]: Networking
Date: Thu, 4 Sep 2008 10:25:14 +0200
Message-ID: <200809041025.15277.rjw@sisk.pl>
References: <20080903.161341.239039051.davem@davemloft.net> <alpine.LFD.1.10.0809031621160.3515@nehalem.linux-foundation.org> <20080903.162603.27086959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, tomasw@gmail.com, yi.zhu@intel.com,
	linville@tuxdriver.com, Jeff Garzik <jeff@garzik.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757365AbYIDIVi@vger.kernel.org>
In-Reply-To: <20080903.162603.27086959.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 4 of September 2008, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Wed, 3 Sep 2008 16:24:16 -0700 (PDT)
> 
> > On Wed, 3 Sep 2008, Linus Torvalds wrote:
> > > 
> > > What's so hard to understand about this?
> > 
> > Here's a simple rule of thumb:
> >  - if it's not on the regression list
> >  - if it's not a reported security hole
> >  - if it's not on the reported oopses list
> > then why are people sending it to me?
> > 
> > IOW, if it's just another random improvement, and you send it to me 
> > outside of the merge window, then what is the point of the merge window? 
> 
> This is exactly what I've been trying to tell the Intel wireless folks
> but they refuse to listen.
> 
> I just won't take their stuff until they get their act in gear.
> 
> No problem.

BTW, there are two regression fixes for forcedeth:

http://marc.info/?l=linux-kernel&m=121894389018584&w=4
http://marc.info/?l=linux-kernel&m=121917167232014&w=4

that fix the regressions tracked as:

http://bugzilla.kernel.org/show_bug.cgi?id=11358
http://bugzilla.kernel.org/show_bug.cgi?id=11361

respectively and both are more than 2 weeks old now.

Is there any chance to push them upstream or is there anything wrong with them?

Thanks,
Rafael
