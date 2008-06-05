From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 26/39] mv643xx_eth: split out rx queue state
Date: Thu, 5 Jun 2008 05:39:33 -0700
Message-ID: <20080605123933.GQ3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-27-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:57065 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756827AbYFEMjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:39:40 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-27-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:41PM +0200, Lennert Buytenhek wrote:
> Split all RX queue related state into 'struct rx_queue', in
> preparation for multiple RX queue support.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |  441 +++++++++++++++++++++++----------------------
>  1 files changed, 225 insertions(+), 216 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
