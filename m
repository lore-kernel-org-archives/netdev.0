From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 18/39] mv643xx_eth: kill superfluous comments
Date: Thu, 5 Jun 2008 05:03:01 -0700
Message-ID: <20080605120301.GI3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-19-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:51219 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756063AbYFEMDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:03:07 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-19-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:33PM +0200, Lennert Buytenhek wrote:
> Half of the functions in the mv643xx_eth driver are prefixed by
> useless and baroque comment blocks on _what_ those functions do (which
> is obvious from the code itself) rather than why, and there's no point
> in keeping those comments around.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |  552 ---------------------------------------------
>  1 files changed, 0 insertions(+), 552 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
