From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 18:20:00 +0100
Message-ID: <20091223172000.GK20539@basil.fritz.box>
References: <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <20091223101340.GC20539@basil.fritz.box> <4B31EF65.6070000@redhat.com> <20091223121431.GF20539@basil.fritz.box> <4B3211A3.1090202@redhat.com> <20091223170017.GB31132@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>, Andi Kleen <andi@firstfloor.org>,
	Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Chris Wright <chrisw@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755658AbZLWRUI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091223170017.GB31132@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > >It seems like there's definitely still potential for improvement
> > >with messages<4K. But for the large messages they indeed
> > >look rather good.
> 
> You are misreading the graph.  At <4K it is tracking bare metal (the
> green and yellow lines are bare metal, the red and blue bars are virtio).
> At >4k we start to drop off (esp. on RX).

I see. True.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
