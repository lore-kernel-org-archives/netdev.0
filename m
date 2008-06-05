From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 08/39] mv643xx_eth: nuke port status register bit
	defines
Date: Thu, 5 Jun 2008 04:26:26 -0700
Message-ID: <20080605112625.GG1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-9-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:51421 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbYFEL03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:26:29 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-9-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:23PM +0200, Lennert Buytenhek wrote:
> None of the port status register bit defines are ever used in the
> mv643xx_eth driver -- nuke them all.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   14 --------------
>  1 files changed, 0 insertions(+), 14 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
