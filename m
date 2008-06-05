From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 05/39] mv643xx_eth: get rid of individual port config
	extend register bit defines
Date: Thu, 5 Jun 2008 04:24:55 -0700
Message-ID: <20080605112455.GE1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-6-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:39288 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754627AbYFELY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:24:59 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-6-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:20PM +0200, Lennert Buytenhek wrote:
> The port config extend register is never changed at run time.
> Document the meaning of the initial value, and delete the defines
> for the individual bits in this register.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   16 ++++------------
>  1 files changed, 4 insertions(+), 12 deletions(-)

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
