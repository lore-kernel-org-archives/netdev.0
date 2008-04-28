From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 3/5] mv643xx_eth: configurable t_clk
Date: Mon, 28 Apr 2008 11:23:54 -0700
Message-ID: <20080428182354.GD2691@farnsworth.org>
References: <20080423232732.GE17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:60134 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936670AbYD1SX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 14:23:58 -0400
Content-Disposition: inline
In-Reply-To: <20080423232732.GE17159@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 01:27:32AM +0200, Lennert Buytenhek wrote:
> Make t_clk configurable via platform device data (with the current
> hardcoded value, 133 MHz, being the default), as it varies across
> different chip families.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Acked-by: Nicolas Pitre <nico@marvell.com>

Acked-by: Dale Farnsworth <dale@farnsworth.org>
