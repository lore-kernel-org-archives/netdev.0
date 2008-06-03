From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] net_dma: remove duplicate assignment in
 dma_skb_copy_datagram_iovec
Date: Tue, 03 Jun 2008 16:07:57 -0700 (PDT)
Message-ID: <20080603.160757.143899512.davem@davemloft.net>
References: <1204305793.31065.4.camel@dwillia2-linux.ch.intel.com>
	<48351A7B.90309@inria.fr>
	<1211489771.16376.24.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, Brice.Goglin@inria.fr,
	netdev@vger.kernel.org, shannon.nelson@intel.com
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52424
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753240AbYFCXH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:07:58 -0400
In-Reply-To: <1211489771.16376.24.camel@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 22 May 2008 13:56:11 -0700

> From: Brice Goglin <Brice.Goglin@inria.fr>
> Subject: net_dma: remove duplicate assignment in dma_skb_copy_datagram_iovec
> 
> No need to compute copy twice in the frags loop in
> dma_skb_copy_datagram_iovec().
> 
> Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> On Thu, 2008-05-22 at 00:02 -0700, Brice Goglin wrote:
> > I don't see this patch applied anywhere, what happened to it?
> >
> > Brice
> 
> Hi Dave,
> 
> Looks like this patch fell by the wayside, here is a resend.

Applied, thanks for resending.
