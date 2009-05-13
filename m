From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/6] powerpc/fsl_rio: use LAW address from device tree
Date: Wed, 13 May 2009 17:08:04 -0500
Message-ID: <CE237554-D711-40AB-8446-6F3398667ED7@kernel.crashing.org>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com> <1242117363-14949-2-git-send-email-leoli@freescale.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	mporter@kernel.crashing.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40368 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759409AbZEMWK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:10:27 -0400
In-Reply-To: <1242117363-14949-2-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 12, 2009, at 3:35 AM, Li Yang wrote:

> Instead of fixed address in old code.
>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
> arch/powerpc/sysdev/fsl_rio.c |   12 +++++++-----
> 1 files changed, 7 insertions(+), 5 deletions(-)

applied to next

- k
