From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 10/39] mv643xx_eth: clarify irq masking and unmasking
Date: Thu, 5 Jun 2008 04:35:53 -0700
Message-ID: <20080605113553.GJ1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-11-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:40274 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017AbYFELf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:35:57 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-11-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:25PM +0200, Lennert Buytenhek wrote:
> Replace the nondescriptive names ETH_INT_UNMASK_ALL and
> ETH_INT_UNMASK_ALL_EXT by names of the actual fields being masked
> and unmasked in the various writes to the interrupt mask registers.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   61 +++++++++++++++++---------------------------
>  1 files changed, 24 insertions(+), 37 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
