From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 09:38:20 -0800
Message-ID: <20071114093820.ff3ad8f9.rdunlap@xenotime.net>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	<20071113.033946.114918709.davem@davemloft.net>
	<20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
	<20071113134029.GA30978@elte.hu>
	<20071113085514.3414aa52.rdunlap@xenotime.net>
	<20071114140847.GA11489@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761638AbXKNRik@vger.kernel.org>
In-Reply-To: <20071114140847.GA11489@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007 15:08:47 +0100 Ingo Molnar wrote:

> 
> * Randy Dunlap <rdunlap@xenotime.net> wrote:
> 
> > > (and this is in no way directed at the networking folks - it holds 
> > > for all of us. I have one main complaint about networking: the 
> > > separate netdev list is a bad idea - networking regressions should 
> > > be discussed and fixed on lkml, like most other subsystems are. Any 
> > > artificial split of the lk discussion space is bad.)
> > 
> > but here I disagree.  LKML is already too busy and noisy. Major 
> > subsystems need their own discussion areas.
> 
> That's a stupid argument. We lose much more by forced isolation of 
> discussion than what we win by having less traffic! It's _MUCH_ easier 
> to narrow down information (by filter by threads, by topics, by people, 
> etc.) than it is to gobble information together from various fractured 
> sources. We learned it _again and again_ that isolation of kernel 
> discussions causes bad things.
> 
> In fact this thread is the very example: David points out that on netdev 
> some of those bugs were already discussed and resolved. Had it been all 
> on lkml we'd all be aware of it.

or had <someone> been on netdev.

> this is a single kernel project that is released together as one 
> codebase, so a central place of discussion is obvious and common-sense.

Central doesn't have to mean one-and-only-one-list-for-everything.

> so please stop this "too busy and too noisy" nonsense already. It was 
> nonsense 10 years ago and it's nonsense today. In 10 years the kernel 
> grew from a 1 million lines codebase to an 8 million lines codebase, so 
> what? Deal with it and be intelligent about filtering your information 
> influx instead of imposing a hard pre-filtering criteria that restricts 
> intelligent processing of information.

So you have a preferred method of handling email.  Please don't
force it on the rest of us.

I'll plan to use lkml-list-only when you have convinced DaveM to drop
all of the other mailing lists at vger.kernel.org.  Yeah, sure.

---
~Randy
