From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 4/5] mv643xx_eth: shorten shared platform driver name
Date: Mon, 28 Apr 2008 11:24:22 -0700
Message-ID: <20080428182422.GE2691@farnsworth.org>
References: <20080423232744.GF17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:60220 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936470AbYD1SY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 14:24:27 -0400
Content-Disposition: inline
In-Reply-To: <20080423232744.GF17159@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 01:27:44AM +0200, Lennert Buytenhek wrote:
> Change the MV643XX_ETH_SHARED_NAME platform driver name to something
> shorter than 19 characters, so that we can register multiple (otherwise
> we end up with sysfs conflicts since all instances will map to
> "mv643xx_eth_shared." as there is a 20-char sysfs file name limit.)
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Acked-by: Nicolas Pitre <nico@marvell.com>

Acked-by: Dale Farnsworth <dale@farnsworth.org>
