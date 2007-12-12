From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] Convert the semaphore to a mutex
 in net/tipc/socket.c
Date: Wed, 12 Dec 2007 11:24:43 -0800 (PST)
Message-ID: <20071212.112443.161687571.davem@davemloft.net>
References: <20071210011741.039692330@gmail.com>
	<20071210011800.543055487@gmail.com>
	<20071211164445.752431ec.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, per.liden@ericsson.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, allan.stephens@windriver.com,
	kjwinchester@gmail.com, mingo@elte.hu
To: akpm@linux-foundation.org
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20071211164445.752431ec.akpm@linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 11 Dec 2007 16:44:45 -0800

> So I'd propose this:

I've applied this to net-2.6, thanks Andrew.

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
