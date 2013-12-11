From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] tipc: cleanups in media and
	bearer layer
Date: Wed, 11 Dec 2013 00:18:45 -0500 (EST)
Message-ID: <20131211.001845.920061009324507763.davem@davemloft.net>
References: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 10 Dec 2013 20:45:37 -0800

> This commit series performs a number cleanups in order to make the 
> bearer and media part of the code more comprehensible and manageable.

When submitting patches targetted at the "net-next" tree, as these
changes must be since they are cleanups/enhancements rather than
bug fixes (which would be targetted at the "net" tree) indicate
this explicitly in your Subject lines by saying "net-next" instead
of "net".

Series applied, thanks.

------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
