From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next v5 8/8] i40e: include i40e in kernel
 proper
Date: Thu, 5 Sep 2013 23:14:36 -0700
Message-ID: <20130905231436.761d03c3@nehalam.linuxnetplumber.net>
References: <1378447278-13998-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378447278-13998-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, gospo@redhat.com,
	davem@davemloft.net, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1378447278-13998-9-git-send-email-jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu,  5 Sep 2013 23:01:18 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> diff --git a/drivers/net/ethernet/intel/i40e/Kbuild b/drivers/net/ethernet/intel/i40e/Kbuild
> new file mode 100644
> index 0000000..479b2c4

Dumb question why is this named Kbuild instead of Makefile like almost
every other network driver?

------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58041391&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
