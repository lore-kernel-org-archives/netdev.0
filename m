From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 15:38:19 -0800
Message-ID: <20071113153819.b1ce6d5b.akpm@linux-foundation.org>
References: <20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
	<20071113.043207.44732743.davem@davemloft.net>
	<20071113193219.GC1356@flint.arm.linux.org.uk>
	<20071113201319.GL4250@stusta.de>
	<20071113232954.GK1356@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, David Miller <davem@davemloft.net>,
        alsa-devel@alsa-project.org, netdev@vger.kernel.org,
        linux-pcmcia@lists.infradead.org, linux-kernel@vger.kernel.org,
        protasnb@gmail.com, linux-ide@vger.kernel.org,
        bugme-daemon@bugzilla.kernel.org, linux-input@atrey.karlin.mff.cuni.cz
To: Russell King <rmk+lkml@arm.linux.org.uk>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113232954.GK1356@flint.arm.linux.org.uk>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 23:29:54 +0000 Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> On Tue, Nov 13, 2007 at 09:13:19PM +0100, Adrian Bunk wrote:
> > On Tue, Nov 13, 2007 at 07:32:19PM +0000, Russell King wrote:
> > >...
> > > There's another issue I want to raise concerning bugzilla.  We have the
> > > classic case of "not enough people reading bugzilla bugs" - which is one
> > > of the biggest problems with bugzilla.  Virtually no one in the ARM
> > > community looks for ARM bugs in bugzilla.
> > > 
> > > Let's not forget that it would be a waste of time for people to manually
> > > check bugzilla for ARM bugs.  There's soo few people reporting ARM bugs
> > > into bugzilla that a weekly manual check by every maintainer would just
> > > return the same old boring results for months and months at a time.
> > >...
> > 
> > What about having all ARM bugs in Bugzilla by default assigned to 
> > linux-arm-kernel@lists.arm.linux.org.uk? [1]
> 
> That would also work, probably much better than setting up yet another
> list.

cpufreq (at least) does it this way.  I don't know how well it is turning
out in practice.

It's useful if the initial report makes it clear (ie; to me) that the report
has already gone to a mailing list so I don't go and forward a duplicate.

But there are so few arm reports in bugzilla that this is all rather moot.

> My experience of trying to get mbligh to do this when I stopped looking
> after PCMCIA stuff was *extremely* painful.  Wonder if it's become any
> easier of late?

He's a bad, bad man ;)

But he's been turning these things around pretty rapidly lately.
