From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 30/39] mv643xx_eth: add tx rate control
Date: Thu, 5 Jun 2008 05:51:50 -0700
Message-ID: <20080605125150.GY3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-31-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:38140 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755821AbYFEMv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:51:57 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-31-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:45PM +0200, Lennert Buytenhek wrote:
> Add an interface for the hardware's per-port and per-subqueue
> TX rate control.  In this stage, this is mainly so that we can
> disable the bandwidth limits during initialisation of the port.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |  104 ++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 103 insertions(+), 1 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
