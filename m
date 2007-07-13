From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [2.6 patch] EP93XX_ETH must select MII
Date: Fri, 13 Jul 2007 09:37:20 +0200
Message-ID: <20070713073720.GC19718@xi.wantstofly.org>
References: <20070713001208.GX3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	John Donoghue <john.donoghue@ieee.org>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:58535 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbXGMHhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 03:37:23 -0400
Content-Disposition: inline
In-Reply-To: <20070713001208.GX3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 02:12:08AM +0200, Adrian Bunk wrote:

> From: John Donoghue <john.donoghue@ieee.org>
> 
> CONFIG_EP93XX_ETH=y, CONFIG_MII=n results in an obvious link error.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
