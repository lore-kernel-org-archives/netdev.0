From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-drivers-2.6 0/9] ixgb: driver update
Date: Sun, 19 Jun 2005 20:22:45 -0400
Message-ID: <20050620002244.GB16859@tuxdriver.com>
References: <Pine.LNX.4.61.0506131232570.24260@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0506131232570.24260@anoushka.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2005 at 04:54:36PM -0700, Malli Chilakala wrote:
> ixgb: driver update

> 1. Set RXDCTL:PTHRESH/HTHRESH to zero 
> 2. Fix unnecessary link state messages
> 3. Use netdev_priv() instead of netdev->priv
> 4. Fix Broadcast/Multicast packets received statistics
> 5. Fix data output by ethtool -d 
> 6. Ethtool cleanup patch from Stephen Hemminger
> 7. Remove unused functions, render some variable static instead of global 
> 8. Redefined buffer_info-dma to be dma_addr_t instead of uint64
> 9. Driver version & white space fixes

Hmmm...I only got parts 1 & 2...anyone else missing parts?

-- 
John W. Linville
linville@tuxdriver.com
