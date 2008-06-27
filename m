From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 06/12] net: use linux/of_{device,platform}.h instead of
 asm
Date: Fri, 27 Jun 2008 00:58:37 -0400
Message-ID: <4864737D.80306@garzik.org>
References: <20080523161627.a75d5010.sfr@canb.auug.org.au> <20080523162854.2e6ea8f0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40829 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451AbYF0E6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 00:58:46 -0400
In-Reply-To: <20080523162854.2e6ea8f0.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Rothwell wrote:
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |    2 +-
>  drivers/net/fs_enet/mac-scc.c      |    2 +-
>  drivers/net/fs_enet/mii-fec.c      |    2 +-
>  drivers/net/ibm_newemac/core.h     |    2 +-
>  drivers/net/ucc_geth.c             |    2 +-
>  drivers/net/ucc_geth_mii.c         |    2 +-
>  6 files changed, 6 insertions(+), 6 deletions(-)

ACK

I'll let a ppc person queue this


