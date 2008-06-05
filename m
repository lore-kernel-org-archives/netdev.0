From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 06/39] mv643xx_eth: delete unused SDMA config register
	bit defines
Date: Thu, 5 Jun 2008 04:25:32 -0700
Message-ID: <20080605112532.GF1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-7-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:39298 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317AbYFELZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:25:39 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-7-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:21PM +0200, Lennert Buytenhek wrote:
> Delete the defines for SDMA config register bit values that are
> never used in the driver, to tidy up the code some more.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   21 ++++-----------------
>  1 files changed, 4 insertions(+), 17 deletions(-)

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
