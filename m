From: Grant Grundler <iod00d@hp.com>
Subject: Re: [patch 2.6.10-rc2] tulip: make tulip_stop_rxtx() wait for DMA to fully stop
Date: Wed, 17 Nov 2004 13:09:54 -0800
Message-ID: <20041117210954.GH4422@cup.hp.com>
References: <20041117151244.B31363@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com,
        grant.grundler@hp.com, charlie.brett@hp.com
Content-Disposition: inline
In-Reply-To: <20041117151244.B31363@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 17, 2004 at 03:12:44PM -0500, John W. Linville wrote:
> tulip_stop_rxtx() doesn't wait for DMA to fully stop like the function
> call name implies.
> 
> Acked-by: Grant Grundler <grant.grundler@hp.com>

John,
I can provide a proper:
	Signed-off-by: Grant Grundler <iod00d@hp.com>

ditto for the 2.4.28 version of the patch.

> This was submitted through my employer -- I am not the original author
> of this patch.  However, I passed it by Jeff Garizk and he expressed
> interest in having it upstream.

Excellent!

thanks,
grant
