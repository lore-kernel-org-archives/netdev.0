From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] sh_eth: add R8A7791 support
Date: Wed, 25 Dec 2013 16:14:51 +0900
Message-ID: <20131225071449.GA27173@verge.net.au>
References: <201312080259.19163.sergei.shtylyov@cogentembedded.com>
 <20131210.214754.1553999236888329751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39658 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab3LYHOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 02:14:55 -0500
Content-Disposition: inline
In-Reply-To: <20131210.214754.1553999236888329751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 09:47:54PM -0500, David Miller wrote:
> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Date: Sun, 8 Dec 2013 02:59:18 +0300
> 
> > Add support for yet another ARM member of the R-Car family, R-Car M2, also known
> > as R8A7791 -- it will share the code and data with previously added R8A7790.
> > Despite the Ether devices in these SoCs are indistinguishable at least from the
> > driver's point of view, we do introduce a new platform device ID "r8a7791-ether"
> > unlike the wildcard ID used for R8A7778/9 SoCs, due to newly established policy
> > for the Renesas SoCs.
> > 
> > Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> Applied, thank you.

Hi Sergei, Hi Dave,

I don't seem to be able to find this in net-next.
