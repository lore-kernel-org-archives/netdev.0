From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v5] net: sh_eth: Add support of device tree probe
Date: Tue, 19 Mar 2013 22:20:37 +0900
Message-ID: <20130319132037.GA22821@verge.net.au>
References: <1362433940-20533-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <20130305004338.GA10651@verge.net.au>
 <20130319042229.GG21444@verge.net.au>
 <514861EF.7050407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	netdev@vger.kernel.org, grant.likely@secretlab.ca,
	kuninori.morimoto.gx@renesas.com,
	devicetree-discuss@lists.ozlabs.org, magnus.damm@gmail.com,
	kda@linux-powerpc.org, Mark Rutland <mark.rutland@arm.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58791 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab3CSNUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 09:20:40 -0400
Content-Disposition: inline
In-Reply-To: <514861EF.7050407@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 05:02:39PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 19-03-2013 8:22, Simon Horman wrote:
> 
> >>[ Cc: Mark Rutland ]
> 
> >>On Tue, Mar 05, 2013 at 06:52:20AM +0900, Nobuhiro Iwamatsu wrote:
> >>>This adds support of device tree probe for Renesas sh-ether driver.
> 
> >>>Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> 
> >>Hi Iwamatsu-san,
> 
> >>could you please address the review by
> >>Mark Rutland of the bindings in this patch.
> >>The review was made for v2 but I believe it
> >>is still applicable to v5.
> 
> >>http://www.spinics.net/lists/netdev/msg226454.html
> 
> >Ping.
> 
>    I don't think converting this driver to device tree can be
> achieved without unravelling the #ifdef mess first (which I'm
> currently doing).
> Or at least the driver will look even uglier than today. So I see
> little use in pinging Iwamatsu-san.

Thanks, I wasn't aware of that.
