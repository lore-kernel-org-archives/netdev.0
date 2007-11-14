From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 21:16:39 +0100
Message-ID: <20071114201639.GA17182@elte.hu>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <20071113085514.3414aa52.rdunlap@xenotime.net> <20071114140847.GA11489@elte.hu> <20071114093820.ff3ad8f9.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
Content-Disposition: inline
In-Reply-To: <20071114093820.ff3ad8f9.rdunlap@xenotime.net>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org


* Randy Dunlap <rdunlap@xenotime.net> wrote:

> On Wed, 14 Nov 2007 15:08:47 +0100 Ingo Molnar wrote:
> 
> > 
> > * Randy Dunlap <rdunlap@xenotime.net> wrote:
> > 
> > > > (and this is in no way directed at the networking folks - it holds 
> > > > for all of us. I have one main complaint about networking: the 
> > > > separate netdev list is a bad idea - networking regressions should 
> > > > be discussed and fixed on lkml, like most other subsystems are. Any 
> > > > artificial split of the lk discussion space is bad.)
> > > 
> > > but here I disagree.  LKML is already too busy and noisy. Major 
> > > subsystems need their own discussion areas.
> > 
> > That's a stupid argument. We lose much more by forced isolation of 
> > discussion than what we win by having less traffic! It's _MUCH_ 
                                                        ^^^^^^^^^^^^
> > easier to narrow down information (by filter by threads, by topics, 
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > by people, etc.) than it is to gobble information together from 
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > various fractured sources. We learned it _again and again_ that 
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > isolation of kernel discussions causes bad things.
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > 
> > In fact this thread is the very example: David points out that on 
> > netdev some of those bugs were already discussed and resolved. Had 
> > it been all on lkml we'd all be aware of it.
> 
> or had <someone> been on netdev.

countered by the underlined sentences above, just in case you missed it.

	Ingo
