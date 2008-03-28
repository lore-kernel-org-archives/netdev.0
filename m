From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 17:03:50 -0700 (PDT)
Message-ID: <20080327.170350.113054010.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F5204C27573@orsmsx418.amr.corp.intel.com>
	<47EC2FE9.5020400@garzik.org> <47EC3393.5010901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, jeff@garzik.org
To: auke-jan.h.kok@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <47EC3393.5010901@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Thu, 27 Mar 2008 16:53:55 -0700

> the only alternative I see is that we have a quirk in the e1000
> driver that acts when the combination of an 82571 and this
> particular chipset is found, but I have no information ATM on the
> chipset id's yet and on how to identify this configuration.

And this is how you will fix this bug, once you know these
IDs.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
