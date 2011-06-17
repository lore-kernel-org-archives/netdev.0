From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: remove unnecessary code
Date: Fri, 17 Jun 2011 00:03:54 -0400 (EDT)
Message-ID: <20110617.000354.1905086622786619545.davem@davemloft.net>
References: <1308244170-30304-1-git-send-email-Gregory.Dietsche@cuw.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, netdev@vger.kernel.org
To: Gregory.Dietsche@cuw.edu
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1308244170-30304-1-git-send-email-Gregory.Dietsche@cuw.edu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Date: Thu, 16 Jun 2011 12:09:30 -0500

> Compile tested.
> remove unnecessary code that matches this coccinelle pattern
> 	if (...)
> 		return ret;
> 	return ret;
> 
> Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>

Applied.

------------------------------------------------------------------------------
EditLive Enterprise is the world's most technically advanced content
authoring tool. Experience the power of Track Changes, Inline Image
Editing and ensure content is compliant with Accessibility Checking.
http://p.sf.net/sfu/ephox-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
