From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 16/39] mv643xx_eth: get rid of ETH_/ethernet_/eth_
	prefixes
Date: Thu, 5 Jun 2008 04:50:58 -0700
Message-ID: <20080605115058.GD3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-17-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:57703 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755772AbYFELvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:51:03 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-17-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:31PM +0200, Lennert Buytenhek wrote:
> The fact that mv643xx_eth is an ethernet driver is pretty obvious,
> and having a lot of internal-use-only functions and defines prefixed
> with ETH_/ethernet_/eth_ prefixes is rather pointless.  So, get rid
> of most of those prefixes.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |  399 ++++++++++++++++++++++-----------------------
>  1 files changed, 195 insertions(+), 204 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
