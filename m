From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 06/12] net: use linux/of_{device,platform}.h instead of asm
Date: Wed, 2 Jul 2008 02:55:29 -0500
Message-ID: <C87095E8-991D-4730-8C5A-B132A3157727@kernel.crashing.org>
References: <20080523161627.a75d5010.sfr@canb.auug.org.au> <20080523162854.2e6ea8f0.sfr@canb.auug.org.au> <4864737D.80306@garzik.org>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, ppc-dev <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41478 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbYGBHzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 03:55:50 -0400
In-Reply-To: <4864737D.80306@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 26, 2008, at 11:58 PM, Jeff Garzik wrote:

> Stephen Rothwell wrote:
>> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> ---
>> drivers/net/fs_enet/fs_enet-main.c |    2 +-
>> drivers/net/fs_enet/mac-scc.c      |    2 +-
>> drivers/net/fs_enet/mii-fec.c      |    2 +-
>> drivers/net/ibm_newemac/core.h     |    2 +-
>> drivers/net/ucc_geth.c             |    2 +-
>> drivers/net/ucc_geth_mii.c         |    2 +-
>> 6 files changed, 6 insertions(+), 6 deletions(-)
>
> ACK
>
> I'll let a ppc person queue this


I'll pick it up (since it mainly touches fsl enet controllers) if you  
can repost it.  I seem to have lost the patch.

- k
