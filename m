From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] [fs_enet] powerpc: Fix SCC Ethernet on CPM2, and crash in fs_enet_rx_napi()
Date: Mon, 18 Aug 2008 09:34:50 -0500
Message-ID: <7993F0B5-401D-46D6-B6BD-29FE56D93905@kernel.crashing.org>
References: <20080612003219.12670.66981.stgit@vitb-lp>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55017 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181AbYHROfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 10:35:31 -0400
In-Reply-To: <20080612003219.12670.66981.stgit@vitb-lp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 11, 2008, at 7:32 PM, Vitaly Bordug wrote:

> From: Heiko Schocher <hs@denx.de>
>
> Initially posted on:
> http://ozlabs.org/pipermail/linuxppc-dev/2008-January/049682.html
> Feedback is addressed in this version (yes, this patch was floating  
> around for a while...)
>
> Signed-off-by: Heiko Schocher <hs@denx.de>
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> ---
>
> drivers/net/fs_enet/fs_enet-main.c |   10 +++++++++-
> drivers/net/fs_enet/mac-scc.c      |    8 +++++++-
> include/asm-powerpc/cpm2.h         |    5 +++++
> 3 files changed, 21 insertions(+), 2 deletions(-)

Jeff, any reason this wasn't picked up ?

- k
