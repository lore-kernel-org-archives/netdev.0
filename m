From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] sh_eth: add R8A7791 support
Date: Thu, 26 Dec 2013 14:38:46 +0900
Message-ID: <20131226053846.GD11739@verge.net.au>
References: <201312080259.19163.sergei.shtylyov@cogentembedded.com>
 <20131210.214754.1553999236888329751.davem@davemloft.net>
 <20131225071449.GA27173@verge.net.au>
 <20131225.225330.1097876354324226061.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131225.225330.1097876354324226061.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 25, 2013 at 10:53:30PM -0500, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Wed, 25 Dec 2013 16:14:51 +0900
> 
> > On Tue, Dec 10, 2013 at 09:47:54PM -0500, David Miller wrote:
> >> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> >> Date: Sun, 8 Dec 2013 02:59:18 +0300
> >> 
> >> > Add support for yet another ARM member of the R-Car family, R-Car M2, also known
> >> > as R8A7791 -- it will share the code and data with previously added R8A7790.
> >> > Despite the Ether devices in these SoCs are indistinguishable at least from the
> >> > driver's point of view, we do introduce a new platform device ID "r8a7791-ether"
> >> > unlike the wildcard ID used for R8A7778/9 SoCs, due to newly established policy
> >> > for the Renesas SoCs.
> >> > 
> >> > Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> >> 
> >> Applied, thank you.
> > 
> > Hi Sergei, Hi Dave,
> > 
> > I don't seem to be able to find this in net-next.
> 
> Check 'net', I might have put it there.

Thanks, I have found it.

I had messed up my remotes and was looking in net instead of net-next.
It is present in net-next.
