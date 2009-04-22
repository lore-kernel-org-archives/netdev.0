From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Wed, 22 Apr 2009 11:39:02 +0000
Message-ID: <20090422113902.GB6630@ff.dom.local>
References: <49EEDAF0.2010507@cosmosbay.com> <20090422101318.GA6630@ff.dom.local> <20090422112612.GA3799@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754880AbZDVLjf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090422112612.GA3799@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 22, 2009 at 01:26:12PM +0200, Ingo Molnar wrote:
> 
> * Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > On 22-04-2009 10:53, Eric Dumazet wrote:
> > ...
> > > If this could be done without recursion, I am pretty sure 
> > > netfilter and network guys would have done it. I found Linus 
> > > reaction quite shocking IMHO, considering hard work done by all 
> > > people on this.
> > 
> > Right, looks like 100% (Scandinavian?!) troll. I wonder where is 
> > the admin of this mess...
> 
> You might disagree with me on an honest technical basis, but note 
> that this kind of childish, knee-jerk reaction against dissenting 
> people is what gives netdev its bad reputation.

How did you find I disagree with you? There was nothing about you,
neither anything technical. Actually, I forgot to mention I agree with
Eric about your locking proposal.

Jarek P.
