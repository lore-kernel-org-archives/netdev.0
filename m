From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: Re: [PATCH v3 1/3] igb: Add igb_disable_sriov in
	error handling
Date: Tue, 23 Dec 2014 23:06:12 +0800
Message-ID: <549984E4.6020406@163.com>
References: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
	<54995097.8090105@cogentembedded.com> <54996CAB.7080007@163.com>
	<1419343393.2470.14.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com, davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1419343393.2470.14.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/23/2014 10:03 PM, Jeff Kirsher wrote:
>
> No it is not.  If you were sending a patch (which has already been
> accepted upstream) to the stable trees, then you would specify what
> stable kernels the patch applies to.  In your case, I would not consider
> your patches critical for the stable trees.
>
> So when sending patches, you inform the maintainer (i.e. me) what tree
> you want your patch applied by stating either "net" or "net-next" in the
> title.  For example, this patch would be titled:
>
> [net v3 1/3] igb: Add igb_disable_sriov in error handling
>
> Which lets me know you want your patch applied to the "net" tree.  If it
> were not a fix, then it would go into the "net-next" tree by using the
> title:
>
> [net-next v3 1/3] igb: Add igb_disable_sriov in error handling
>
>

Thanks!


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
