From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 15:17:29 -0800
Message-ID: <20071113151729.3291c889.akpm@linux-foundation.org>
References: <20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
	<20071113.043207.44732743.davem@davemloft.net>
	<20071113193219.GC1356@flint.arm.linux.org.uk>
	<20071113125222.9eb53ac8.akpm@linux-foundation.org>
	<20071113221801.GF1356@flint.arm.linux.org.uk>
	<20071113143201.9441c940.akpm@linux-foundation.org>
	<20071113230936.GI1356@flint.arm.linux.org.uk>
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
In-Reply-To: <20071113230936.GI1356@flint.arm.linux.org.uk>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 23:09:37 +0000 Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> On Tue, Nov 13, 2007 at 02:32:01PM -0800, Andrew Morton wrote:
> > On Tue, 13 Nov 2007 22:18:01 +0000 Russell King <rmk+lkml@arm.linux.org.uk> wrote:
> > > On Tue, Nov 13, 2007 at 12:52:22PM -0800, Andrew Morton wrote:
> > > > On Tue, 13 Nov 2007 19:32:19 +0000 Russell King <rmk+lkml@arm.linux.org.uk> wrote:
> > No, I don't mean that at all and this was very plainly obviously from my very
> > clearly written email.  Let me try again.
> 
> If you screen all bugzilla reports then you'll know that bug #9356 arrived
> at about 1400 GMT yesterday.  It's hardly surprising then that your utterly
> crappy responses to Natalie's message (which, incidentally, wasn't copied
> to me) sent within 24 hours of that report cause *great* annoyance.
> 
> > No, no subsystem developer needs to monitor new bugzilla reports.  This is
> > because *I do it for them*.  I will actively make them aware of new reports
> > which I believe are legitimate and which contain sufficient information for
> > them to be able to take further action.
> 
> On the whole you do an excellent job with feeding the bug reports to
> people, and while I recognise that you're only human, things do
> occasionally go wrong.  For instance, sending clearly marked Samsung
> S3C bugs to me rather than Ben Dooks (who's in MAINTAINERS for those
> platforms.)


Well whatever, sorry.  But this is in the noise floor.  Point is: many bug
reports aren't being attended to.


> > > > > It would be far more productive if the ARM category was deleted from
> > > > > bugzilla and the few people who use bugzilla reported their bugs on the
> > > > > mailing list.  We've a couple of thousand people on the ARM kernel
> > > > > mailing list at the moment - that's 3 orders of magnitude more of eyes
> > > > > than look at bugzilla.
> > > > 
> > > > Is that linux-arm-kernel@lists.arm.linux.org.uk?
> > > 
> > > Yes.
> > > 
> > > > If so, MANITAINERS claims that it is subscribers-only.  That would cause
> > > > some bug reporters to give up and go away.
> > > 
> > > Find some other mailing list; I'm not hosting *nor* am I willing to run a
> > > non-subscribers only mailing list.  Period.  Not negotiable, so don't even
> > > try to change my mind.
> > 
> > Making a list subscribers-only will cause some bug reports to be lost.
> > 
> > Tradeoffs are involved, against which decisions must be made.  You have
> > made yours.
> 
> So how are they lost when they're held in a moderation queue and are
> either accepted, a useful response given to the original poster, or
> are forwarded to someone who can deal with the issue.
> 
> I don't think "subscribers only" describes my lists - we don't devnull
> stuff just because the poster is not a subscriber.

Oh, OK, as long as there really is a human paying attention to those things
then that's fine.  When one is on the sending end of these things one never
knows how long it will take, not whether it will even happen.
