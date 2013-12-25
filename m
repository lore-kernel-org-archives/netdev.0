From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] sh_eth: add R8A7791 support
Date: Wed, 25 Dec 2013 23:35:26 +0900
Message-ID: <20131225143519.GA29115@verge.net.au>
References: <201312080259.19163.sergei.shtylyov@cogentembedded.com>
 <20131210.214754.1553999236888329751.davem@davemloft.net>
 <20131225071449.GA27173@verge.net.au>
 <52BABC13.201@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52BABC13.201@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 25, 2013 at 03:05:55PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 25-12-2013 11:14, Simon Horman wrote:
> 
> >>>Add support for yet another ARM member of the R-Car family, R-Car M2, also known
> >>>as R8A7791 -- it will share the code and data with previously added R8A7790.
> >>>Despite the Ether devices in these SoCs are indistinguishable at least from the
> >>>driver's point of view, we do introduce a new platform device ID "r8a7791-ether"
> >>>unlike the wildcard ID used for R8A7778/9 SoCs, due to newly established policy
> >>>for the Renesas SoCs.
> 
> >>>Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> >>Applied, thank you.
> 
> >Hi Sergei, Hi Dave,
> 
> >I don't seem to be able to find this in net-next.
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=94a12b15e4c575e0aa0ba5e24a4f213163a823d0

Thanks
