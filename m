From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [net-next v5 8/8] i40e: include i40e in kernel
 proper
Date: Fri, 6 Sep 2013 11:30:30 -0700
Message-ID: <20130906113030.000034a7@unknown>
References: <1378447278-13998-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130905231436.761d03c3@nehalam.linuxnetplumber.net>
	<C0F8C5F1-0D98-4297-ACC9-55BB9C889FEB@intel.com>
	<20130906.140141.2245821068783126791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130906.140141.2245821068783126791.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 6 Sep 2013 14:01:41 -0400
David Miller <davem@davemloft.net> wrote:
> Please rename this Kbuild file to the normal Makefile instead of
> trying to be different from every single other driver in the
> networking for the sake of an issue that is your, and your problem
> alone.

Thanks Dave, will do, I'm preparing the patch now.

> You guys should really be grateful that anyone at all not being paid
> to do so is reviewing such a huge body of code for you, rather than
> complaining that all the issues weren't discovered the first time
> this series was posted.

We *are* really grateful for all the effort of any/all reviewers.  I
would like to personally thank you Dave, Joe Perches, Ben Hutchings,
and Stephen Hemminger for the non-trival amount of time spent on
reviewing this patch set.

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
