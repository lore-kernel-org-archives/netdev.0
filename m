From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [lkp] [rhashtable] 9d901bc0515: WARNING: CPU: 0 PID: 1 at
 arch/x86/mm/ioremap.c:63 __ioremap_check_ram+0x6a/0x99()
Date: Fri, 21 Aug 2015 15:22:29 +0800
Message-ID: <20150821072229.GA6166@gondor.apana.org.au>
References: <87fv3dkwgw.fsf@yhuang-dev.intel.com>
 <20150821064207.GA5835@gondor.apana.org.au>
 <1440140982.8683.32.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkp@01.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Huang Ying <ying.huang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47931 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbbHUHWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 03:22:38 -0400
Content-Disposition: inline
In-Reply-To: <1440140982.8683.32.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 21, 2015 at 03:09:42PM +0800, Huang Ying wrote:
> 
> Sorry, my fault.  There are OOM for parent commit too, just some dmesg
> difference, which I miss understood.  Please ignore this report.  I
> will be more careful next time.

Thanks for the confirmation.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
