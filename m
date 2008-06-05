From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 15/39] mv643xx_eth: clean up rx/tx descriptor field
	defines
Date: Thu, 5 Jun 2008 04:37:03 -0700
Message-ID: <20080605113703.GK1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-16-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:40299 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443AbYFELhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:37:10 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-16-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:30PM +0200, Lennert Buytenhek wrote:
> Remove the unused rx/tx descriptor field defines, and move the ones
> that are actually used to the actual definitions of the rx/tx
> descriptor format.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   82 +++++++++++++++-----------------------------
>  1 files changed, 28 insertions(+), 54 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
