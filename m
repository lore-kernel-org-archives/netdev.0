From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-drivers-2.6 0/9] ixgb: driver update
Date: Mon, 27 Jun 2005 00:37:43 -0400
Message-ID: <42BF8297.9050503@pobox.com>
References: <Pine.LNX.4.61.0506131232570.24260@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Malli Chilakala <mallikarjuna.chilakala@intel.com>
In-Reply-To: <Pine.LNX.4.61.0506131232570.24260@anoushka.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Malli Chilakala wrote:
> ixgb: driver update
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
> Signed-off-by: John Ronciak <john.ronciak@intel.com>
>  
> 1. Set RXDCTL:PTHRESH/HTHRESH to zero 
> 2. Fix unnecessary link state messages
> 3. Use netdev_priv() instead of netdev->priv
> 4. Fix Broadcast/Multicast packets received statistics
> 5. Fix data output by ethtool -d 
> 6. Ethtool cleanup patch from Stephen Hemminger
> 7. Remove unused functions, render some variable static instead of global 
> 8. Redefined buffer_info-dma to be dma_addr_t instead of uint64
> 9. Driver version & white space fixes

also, please take Francois' comments into account...
