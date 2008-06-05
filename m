From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 20/39] mv643xx_eth: get rid of hungarian variable naming
Date: Thu, 5 Jun 2008 05:06:20 -0700
Message-ID: <20080605120620.GK3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-21-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:53501 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756152AbYFEMG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:06:27 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-21-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:35PM +0200, Lennert Buytenhek wrote:
> Nuke some Hungarian-esque variable naming conventions:
> - p_ prefix for pointers
> - _q suffix for variables dealing with rx/tx queue state
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |  156 ++++++++++++++++++++++----------------------
>  1 files changed, 78 insertions(+), 78 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
