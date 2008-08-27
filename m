From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][for 2.6.27] fs_enet: Fix SCC Ethernet on CPM2, and crash
 in fs_enet_rx_napi()
Date: Wed, 27 Aug 2008 05:19:14 -0400
Message-ID: <48B51C12.8060408@garzik.org>
References: <Pine.LNX.4.64.0808252019030.20949@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, hs@denx.de, vitb@kernel.crashing.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45259 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753738AbYH0JTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:19:19 -0400
In-Reply-To: <Pine.LNX.4.64.0808252019030.20949@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> From: Heiko Schocher <hs@denx.de>
> 
> Signed-off-by: Heiko Schocher <hs@denx.de>
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> ---
> 
> Updated to apply cleanly to top of linus's tree.
> 
> - k
> 
>  arch/powerpc/include/asm/cpm2.h    |    5 +++++
>  drivers/net/fs_enet/fs_enet-main.c |    8 ++++++++
>  drivers/net/fs_enet/mac-scc.c      |    8 +++++++-
>  3 files changed, 20 insertions(+), 1 deletions(-)

applied


