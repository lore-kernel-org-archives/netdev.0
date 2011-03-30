From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] netfilter: Fix build failure when ipv6 but xt_tproxy
 is built in
Date: Wed, 30 Mar 2011 06:18:20 -0400
Message-ID: <1301480300.14261.332.camel@gandalf.stny.rr.com>
References: <1301451199.14261.327.camel@gandalf.stny.rr.com>
	 <20110329.223536.245392030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hidden@balabit.hu,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110329.223536.245392030.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-03-29 at 22:35 -0700, David Miller wrote:
> From: Steven Rostedt <rostedt@goodmis.org>
> Date: Tue, 29 Mar 2011 22:13:19 -0400
> 
> > While running ktest.pl doing ranconfigs, the following build error
> > occurred:
> 
> Is sending netfilter patches to the explicitly listed maintainer in
> MAINTAINERS too much to ask Stephen? :-/
> 
> CC:'d
> 

Sorry David, I just did a git blame and Cc'd the ones that did the
original change. I'll do better next time.

-- Steve


