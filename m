From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 12/39] mv643xx_eth: get rid of RX_BUF_OFFSET
Date: Thu, 5 Jun 2008 04:37:47 -0700
Message-ID: <20080605113747.GL1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-13-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:40308 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755281AbYFELhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:37:51 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-13-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:27PM +0200, Lennert Buytenhek wrote:
> Get rid of RX_BUF_OFFSET (which is synonymous with ETH_HW_IP_ALIGN).
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
