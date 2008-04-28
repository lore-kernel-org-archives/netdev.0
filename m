From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 2/5] mv643xx_eth: mbus decode window support
Date: Mon, 28 Apr 2008 11:23:28 -0700
Message-ID: <20080428182328.GC2691@farnsworth.org>
References: <20080423232717.GD17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:51609 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936596AbYD1SXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 14:23:36 -0400
Content-Disposition: inline
In-Reply-To: <20080423232717.GD17159@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 01:27:17AM +0200, Lennert Buytenhek wrote:
> Make it possible to pass mbus_dram_target_info to the mv643xx_eth
> driver via the platform data, and make the mv643xx_eth driver
> program the window registers based on this data if it is passed in.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Reviewed-by: Tzachi Perelstein <tzachi@marvell.com>
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Acked-by: Dale Farnsworth <dale@farnsworth.org>
