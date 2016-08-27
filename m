From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] tipc: introduce UDP
	replicast
Date: Fri, 26 Aug 2016 21:40:30 -0700 (PDT)
Message-ID: <20160826.214030.1723676910148934436.davem@davemloft.net>
References: <1472201576-26588-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1472201576-26588-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Fri, 26 Aug 2016 10:52:49 +0200

> This series introduces UDP replicast. A concept where we emulate multicast by
> sending multiple unicast messages to configured peers. This allows TIPC to be
> used in environments where IP multicast is disabled.
> 
> There is a corresponding patch series for the tipc user space tool that
> allows a user to add remote addresses to the replicast list.

Series applied, thanks.

------------------------------------------------------------------------------
