From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHSET 0/8] PKT_SCHED: Use gnet_stats for actions and policer
Date: Thu, 4 Nov 2004 01:43:27 +0100
Message-ID: <20041104004327.GJ12289@postel.suug.ch>
References: <20041103215816.GA12289@postel.suug.ch> <20041103141820.7a0c7832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041103141820.7a0c7832.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20041103141820.7a0c7832.davem@davemloft.net> 2004-11-03 14:18
> > Shall I mark the old estimator and statistic API as __deprecated
> > or remove it right away?
> 
> Since nothing in the tree uses it any more, let's just kill it
> outright.

I will come up with a patch tomorrow together with the iproute2
patch which needs some more work. Thanks for the quick applying.
