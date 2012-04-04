From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 00/28] ethtool: support time
 stamping and phc clocks
Date: Wed, 04 Apr 2012 01:36:54 -0400 (EDT)
Message-ID: <20120404.013654.178303235851473916.davem@davemloft.net>
References: <cover.1333474520.git.richardcochran@gmail.com>
	<20120403.162542.2077088434639546515.davem@davemloft.net>
	<20120404051431.GA3328@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mporter@solarflare.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, bhutchings@solarflare.com
To: richardcochran@gmail.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120404051431.GA3328@netboy.at.omicron.at>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 4 Apr 2012 07:14:32 +0200

> On Tue, Apr 03, 2012 at 04:25:42PM -0400, David Miller wrote:
> 
>> If these patches depend upon changes not in my tree, and you haven't
>> even mentioned this, I'm going to be _extremely_ irritated.
> 
> Sorry for being so irritating, and not being clear enough about
> this. I did mention that
> 
>    Patch number  3 applies on top of my recent two igb/phc patches.
>    Patch number 12 applies on top of my recent e100 patch.
> 
> Jeff accepted all of those 'recent patches' into his queue, so perhaps
> he would take #3 and #12.
> 
> Or should I just drop them for now?

Yes, you can drop them and then send them later through Jeff once
the infrastructure hits my tree.

------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
