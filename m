From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 23/39] mv643xx_eth: kill FUNC_RET_STATUS/pkt_info
Date: Thu, 5 Jun 2008 04:59:44 -0700
Message-ID: <20080605115944.GG3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-24-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:56875 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755945AbYFEL7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:59:48 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-24-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:38PM +0200, Lennert Buytenhek wrote:
> Since they are no longer used, kill enum FUNC_RET_STATUS and
> struct pkt_info (which were a rather roundabout way of communicating
> RX/TX status within the same driver).
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   21 ---------------------
>  1 files changed, 0 insertions(+), 21 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
