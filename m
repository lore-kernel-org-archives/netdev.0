From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] tipc: replace 0 by NULL
	for pointers
Date: Wed, 31 Dec 2014 13:11:59 -0500 (EST)
Message-ID: <20141231.131159.1962969227546395849.davem@davemloft.net>
References: <1419505550-17336-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, allan.stephens@windriver.com
To: fabf@skynet.be
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1419505550-17336-1-git-send-email-fabf@skynet.be>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Thu, 25 Dec 2014 12:05:50 +0100

> Fix sparse warning:
> net/tipc/link.c:1924:40: warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, thanks.

------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
