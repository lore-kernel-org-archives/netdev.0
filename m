From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for
	ndo_ll_poll
Date: Tue, 21 May 2013 11:43:23 +0300
Message-ID: <CAJZOPZJD5QpkmkJF9qpWV3Q28aioLw5CuT5X4URxDC4eSby3nQ@mail.gmail.com>
References: <1369120003.25971.2.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130521.001444.1361294042663568537.davem@davemloft.net>
	<CAJZOPZJTA9A8T4R8MtRCeqcYj3XJWFCXF+ojmEqza5TMj-6G+w@mail.gmail.com>
	<20130521.013912.96249995742935192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, eliezer.tamir@linux.intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	hpa@zytor.com, jesse.brandeburg@intel.com, eliezer@tamir.org.il,
	linux-kernel@vger.kernel.org, andi@firstfloor.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130521.013912.96249995742935192.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2013 at 11:39 AM, David Miller <davem@davemloft.net> wrote:

> It's one of those "implementation details", I hate it too.

Maybe if we bake it on this list little further we can see how to get
away from that, or what's the most non ugly way for that?

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
