From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/5] netdev: show a process of packets
Date: Thu, 02 Sep 2010 19:17:41 -0700 (PDT)
Message-ID: <20100902.191741.233696520.davem@davemloft.net>
References: <4C72422C.5070102@jp.fujitsu.com>
	<1283212210.3656.84.camel@gandalf.stny.rr.com>
	<4C80592B.2060406@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	nhorman@tuxdriver.com, laijs@cn.fujitsu.com,
	scott.a.mcmillan@intel.com, eric.dumazet@gmail.com,
	fweisbec@gmail.com, mathieu.desnoyers@polymtl.ca
To: sanagi.koki@jp.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C80592B.2060406@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Date: Fri, 03 Sep 2010 11:10:51 +0900

> Thanks many acks. and I have one question.
> 
> These patches have several component.
> 
> Patch1 is kernel component, but patch2-5 are netdev component.
> What tree is good to be included ?
> If it is not net-next, I must rebase to another tree.

I would prefer it goes into the tracing tree or whatever is the most appropriate
for patch #1.
