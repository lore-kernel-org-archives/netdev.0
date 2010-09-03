From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v4 0/5] netdev: show a process of packets
Date: Fri, 3 Sep 2010 06:46:58 +0200
Message-ID: <20100903044656.GA6589@nowhere>
References: <4C72422C.5070102@jp.fujitsu.com> <1283212210.3656.84.camel@gandalf.stny.rr.com> <4C80592B.2060406@jp.fujitsu.com> <20100902.191741.233696520.davem@davemloft.net> <4C806388.9020509@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	eric.dumazet@gmail.com, mathieu.desnoyers@polymtl.ca
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C806388.9020509@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 03, 2010 at 11:55:04AM +0900, Koki Sanagi wrote:
> (2010/09/03 11:17), David Miller wrote:
> > From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> > Date: Fri, 03 Sep 2010 11:10:51 +0900
> > 
> >> Thanks many acks. and I have one question.
> >>
> >> These patches have several component.
> >>
> >> Patch1 is kernel component, but patch2-5 are netdev component.
> >> What tree is good to be included ?
> >> If it is not net-next, I must rebase to another tree.
> > 
> > I would prefer it goes into the tracing tree or whatever is the most appropriate
> > for patch #1.
> > 
> 
> O.K. I'll rebase to linux-2.6-tip.


No need, they apply very well :)

I'll push that to -tip soon.

Thanks.
