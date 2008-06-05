From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 03/39] mv643xx_eth: shorten reg names
Date: Thu, 5 Jun 2008 04:21:19 -0700
Message-ID: <20080605112119.GC1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-4-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:39213 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433AbYFELVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:21:24 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-4-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:18PM +0200, Lennert Buytenhek wrote:
> Shorten the various oversized register names in mv643xx_eth.c, to
> increase readability.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |  204 +++++++++++++++++++++------------------------
>  1 files changed, 96 insertions(+), 108 deletions(-)

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
