From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 31/39] mv643xx_eth: allow multiple RX queues
Date: Thu, 5 Jun 2008 05:35:36 -0700
Message-ID: <20080605123535.GO3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-32-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:60454 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756783AbYFEMfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:35:44 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-32-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:46PM +0200, Lennert Buytenhek wrote:
> Allow the platform code to specify that we are running on hardware
> that is capable of supporting multiple RX queues.  If this option
> is used, initialise all of the given RX queues instead of just RX
> queue zero.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c   |   99 ++++++++++++++++++++++++++++++++-----------

Acked-by: Dale Farnsworth <dale@farnsworth.org>
