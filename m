From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 14:32:01 -0800
Message-ID: <20071113143201.9441c940.akpm@linux-foundation.org>
References: <20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
	<20071113.043207.44732743.davem@davemloft.net>
	<20071113193219.GC1356@flint.arm.linux.org.uk>
	<20071113125222.9eb53ac8.akpm@linux-foundation.org>
	<20071113221801.GF1356@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alsa-devel@alsa-project.org,
        netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
        linux-kernel@vger.kernel.org, protasnb@gmail.com,
        linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
        linux-input@atrey.karlin.mff.cuni.cz
To: Russell King <rmk+lkml@arm.linux.org.uk>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113221801.GF1356@flint.arm.linux.org.uk>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 22:18:01 +0000 Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> On Tue, Nov 13, 2007 at 12:52:22PM -0800, Andrew Morton wrote:
> > On Tue, 13 Nov 2007 19:32:19 +0000 Russell King <rmk+lkml@arm.linux.org.uk> wrote:
> > > There's another issue I want to raise concerning bugzilla.  We have the
> > > classic case of "not enough people reading bugzilla bugs" - which is one
> > > of the biggest problems with bugzilla.  Virtually no one in the ARM
> > > community looks for ARM bugs in bugzilla.
> > 
> > Nor should they.
> 
> So what you're saying is...
> 
> > > Let's not forget that it would be a waste of time for people to manually
> > > check bugzilla for ARM bugs.  There's soo few people reporting ARM bugs
> > > into bugzilla that a weekly manual check by every maintainer would just
> > > return the same old boring results for months and months at a time.
> > 
> > I screen all bugzilla reports.  100% of them.
> > 
> > - I'll try to establish whether it is a regression
> > 
> > - I'll solicit any extra information which I believe the reveloper will need
> > 
> > - I'll ensure that an appropriate developer has seen the report
> > 
> > And yes, the number of arm-specific reports in there is very small.
> 
> that just because you do this everyone in a select clique, who you include
> me in, should be doing this as well.
> 
> No.  Thank.  You.

No, I don't mean that at all and this was very plainly obviously from my very
clearly written email.  Let me try again.

No, no subsystem developer needs to monitor new bugzilla reports.  This is
because *I do it for them*.  I will actively make them aware of new reports
which I believe are legitimate and which contain sufficient information for
them to be able to take further action.

> > > It would be far more productive if the ARM category was deleted from
> > > bugzilla and the few people who use bugzilla reported their bugs on the
> > > mailing list.  We've a couple of thousand people on the ARM kernel
> > > mailing list at the moment - that's 3 orders of magnitude more of eyes
> > > than look at bugzilla.
> > 
> > Is that linux-arm-kernel@lists.arm.linux.org.uk?
> 
> Yes.
> 
> > If so, MANITAINERS claims that it is subscribers-only.  That would cause
> > some bug reporters to give up and go away.
> 
> Find some other mailing list; I'm not hosting *nor* am I willing to run a
> non-subscribers only mailing list.  Period.  Not negotiable, so don't even
> try to change my mind.

Making a list subscribers-only will cause some bug reports to be lost.

Tradeoffs are involved, against which decisions must be made.  You have
made yours.
