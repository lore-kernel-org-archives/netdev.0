From: David Miller <davem@davemloft.net>
Subject: Re: Debounce code vs. dma_sync_single_range_for_cpu()
 and e100 driver.
Date: Tue, 14 Jul 2009 14:05:07 -0700 (PDT)
Message-ID: <20090714.140507.211725964.davem@davemloft.net>
References: <m3d483m53q.fsf@intrepid.localdomain>
	<20090714.123848.189674670.davem@davemloft.net>
	<m38wirm119.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com
To: khc@pm.waw.pl
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <m38wirm119.fsf@intrepid.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Tue, 14 Jul 2009 23:01:54 +0200

> Maybe you apply the workaround for 2.6.31 and I (or someone) will
> convert e100 to coherent allocs for packet descriptors, post-31?

I think that's a good plan.

Will give a few days for Intel folks to chime in before applying
your patch for 2.6.31, but otherwise that's my plan.

------------------------------------------------------------------------------
Enter the BlackBerry Developer Challenge  
This is your chance to win up to $100,000 in prizes! For a limited time, 
vendors submitting new applications to BlackBerry App World(TM) will have
the opportunity to enter the BlackBerry Developer Challenge. See full prize  
details at: http://p.sf.net/sfu/Challenge
