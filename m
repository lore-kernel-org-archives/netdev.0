From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 06/12] net: use linux/of_{device,platform}.h instead of asm
Date: Fri, 23 May 2008 02:09:56 -0500
Message-ID: <F06C1CB1-2A8E-4084-B6EA-7D1D8875E93E@kernel.crashing.org>
References: <20080523161627.a75d5010.sfr@canb.auug.org.au> <20080523162854.2e6ea8f0.sfr@canb.auug.org.au>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, ppc-dev <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38765 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755991AbYEWHLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 03:11:10 -0400
In-Reply-To: <20080523162854.2e6ea8f0.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 23, 2008, at 1:28 AM, Stephen Rothwell wrote:

>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
> drivers/net/fs_enet/fs_enet-main.c |    2 +-
> drivers/net/fs_enet/mac-scc.c      |    2 +-
> drivers/net/fs_enet/mii-fec.c      |    2 +-
> drivers/net/ibm_newemac/core.h     |    2 +-
> drivers/net/ucc_geth.c             |    2 +-
> drivers/net/ucc_geth_mii.c         |    2 +-
> 6 files changed, 6 insertions(+), 6 deletions(-)

Acked-by: Kumar Gala <galak@kernel.crashing.org>

- k
