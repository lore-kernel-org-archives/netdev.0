From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for
	ndo_ll_poll
Date: Tue, 21 May 2013 09:23:08 +0300
Message-ID: <CAJZOPZJVidn+umCvpcyB0Xf_Ah0ycezAN_CeaBKtx1UV7bggVw@mail.gmail.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<20130520101622.14133.21998.stgit@ladj378.jer.intel.com>
	<CAJZOPZJx8vpSWqOhmN65gn=vi7hWXQO_J01+hAwGY9RwetX3DA@mail.gmail.com>
	<20130520203307.GE24555@two.firstfloor.org>
	<CAJZOPZJwcgShs-FCaXmPmigdu55ZSt08WnJjadcOi+-_AMq=oA@mail.gmail.com>
	<20130520210127.GF24555@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Eliezer Tamir <eliezer@tamir.org.il>,
	Dave Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130520210127.GF24555@two.firstfloor.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2013 at 12:01 AM, Andi Kleen <andi@firstfloor.org> wrote:
>
> On Mon, May 20, 2013 at 11:42:37PM +0300, Or Gerlitz wrote:
> > On Mon, May 20, 2013 at 11:33 PM, Andi Kleen <andi@firstfloor.org> wrote:
> >
> > >
> > > This is discussed in 0/x
> > >
> >
> > I am not with you, V3's cover letter is empty, and in V2's cover letter I
> > don't see that
>
> It was here. Looks like Eliezer didn't reuse the full cover later.
> http://www.gossamer-threads.com/lists/linux/kernel/1715294?page=last
>


Grepping for "ixgbe" in the link you sent only brings the following hits:

Patch 3 shows how this method would be implemented for the ixgbe driver.
Patch 4 adds statistics to the ixgbe driver for ndo_ll_poll events.

does "shows how this method would be implemented" means patch #4 is
just RFC or proof-of-concept code and is not actually submitted for
acceptance?

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
