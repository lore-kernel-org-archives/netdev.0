From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] tipc: add broadcast link
 window set/get to nl api
Date: Sat, 09 May 2015 16:40:20 -0400 (EDT)
Message-ID: <20150509.164020.2169198004350517186.davem@davemloft.net>
References: <1430913536-4206-1-git-send-email-richard.alpe@ericsson.com>
	<1430913536-4206-2-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1430913536-4206-2-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: <richard.alpe@ericsson.com>
Date: Wed, 6 May 2015 13:58:55 +0200

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> Add the ability to get or set the broadcast link window through the
> new netlink API. The functionality was unintentionally missing from
> the new netlink API. Adding this means that we also fix the breakage
> in the old API when coming through the compat layer.
> 
> Fixes: 37e2d4843f9e (tipc: convert legacy nl link prop set to nl compat)
> Reported-by: Tomi Ollila <tomi.ollila@iki.fi>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied.

------------------------------------------------------------------------------
One dashboard for servers and applications across Physical-Virtual-Cloud 
Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
