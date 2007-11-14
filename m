From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 21:35:52 +0100
Message-ID: <20071114203552.GB17182@elte.hu>
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

> > so please stop this "too busy and too noisy" nonsense already. It 
> > was nonsense 10 years ago and it's nonsense today. In 10 years the 
> > kernel grew from a 1 million lines codebase to an 8 million lines 
> > codebase, so what? Deal with it and be intelligent about filtering 
> > your information influx instead of imposing a hard pre-filtering 
> > criteria that restricts intelligent processing of information.
> 
> So you have a preferred method of handling email.  Please don't force 
> it on the rest of us.

actually, posting to lkml is the preferred method of handling 
development for like 70% of all Linux kernel activities. It is _YOU_ who 
is the sore thumb sticking out, it is you who is forcing people to Cc: 
around various stupid fractured lists for no good reason. You dont have 
to read all of lkml, just like you dont read all of netdev either.

once someone decides to work on Linux, information should be 
fundamentally opt-out, not opt-in. And there should be a central place 
for people to go to. The "Subject:" line is enough of a filter key - in 
fact it's _far superior_ to the forced separation of topics that you 
advocate! Fact is, many regressions happen because they were posted to 
the wrong list and got ignored or under-handled. I claim that we'd have 
a much higher quality kernel if we had a single central mailing list 
instead of these elitist fractured lists. Every kernel topic would have 
global visibility, and it would be trivially easy to get the interest of 
other people, across subsystems.

damn, THINK ABOUT IT instead of just ignorantly dismissing my points 
without even answering them... Often when someone writes to the wrong 
list and he is told "wrong list", he'd have to repost to the "right 
list". Lots of extra bounces for the tester for _NO GOOD REASON_. All 
just because a few developers are too lazy to filter the lkml subjects 
for their main topic of interest.

I claim that we have far larger lack of testing resources than we have a 
lack of development resources. So we might as well set up our mailing 
lists to favor information sharing, instead of imposing this insane 
separation of lists that some subsystems still insist on. We can 
evidently throttle development activities by forcing _every subsystem_ 
to lkml and exposing them to the harsh combined realities of all the 
crap that we are are writing. Life might look nice and easy on an 
isolated list, and it's sure convenient not being exposed to ... users. 

THAT is our main problem, not your bogus "lkml has too much traffic" 
argument.

	Ingo
