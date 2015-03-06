From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tipc: increase size of
 tipc discovery messages
Date: Thu, 05 Mar 2015 22:09:55 -0500 (EST)
Message-ID: <20150305.220955.2118659556405822694.davem@davemloft.net>
References: <1425547429-21164-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1425547429-21164-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: <erik.hugne@ericsson.com>
Date: Thu, 5 Mar 2015 10:23:48 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> The payload area following the TIPC discovery message header is an
> opaque area defined by the media. INT_H_SIZE was enough for
> Ethernet/IB/IPv4 but needs to be expanded to carry IPv6 addressing
> information.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

Applied.

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
