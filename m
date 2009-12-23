From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 18:33:39 +0100
Message-ID: <20091223173339.GL20539@basil.fritz.box>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <20091223171052.GI20539@basil.fritz.box> <4B3250BC.50203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B3250BC.50203@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 12:17:48PM -0500, Gregory Haskins wrote:
> On 12/23/09 12:10 PM, Andi Kleen wrote:
> >> And its moot, anyway, as I have already retracted my one outstanding
> >> pull request based on Linus' observation.  So at this time, I am not
> >> advocating _anything_ for upstream inclusion.  And I am contemplating
> >> _never_ doing so again.  It's not worth _this_.
> > 
> > That certainly sounds like the wrong reaction. Out of tree drivers
> > are typically a pain to use.
> 
> Well, to Linus' point, it shouldn't go in until a critical mass of users
> have expressed desire to see it in tree, which seems reasonable to me.
> For the admittedly small group that are using it today, modern tools
> like the opensuse-build-service ease the deployment as a KMP, so that
> can suffice for now.  Its actually what most of the alacrityvm community
> uses today anyway (as opposed to using a merged tree in the guest)

It would be probably also good to have some more exhaustive data 
showing any performance improvements.

Your numbers are very hard to compare to Chris' numbers and not
as comprehensive (e.g. no latencies)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
