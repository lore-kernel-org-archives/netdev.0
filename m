From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 27/39] mv643xx_eth: split out tx queue state
Date: Thu, 5 Jun 2008 05:09:41 -0700
Message-ID: <20080605120941.GM3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-28-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:53552 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756513AbYFEMJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:09:48 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-28-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:42PM +0200, Lennert Buytenhek wrote:
> Split all TX queue related state into 'struct tx_queue', in
> preparation for multiple TX queue support.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |  510 ++++++++++++++++++++++-----------------------
>  1 files changed, 254 insertions(+), 256 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
