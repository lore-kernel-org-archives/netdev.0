From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers: net: ethernet: 8390: Kconfig: add
 H8300H_AKI3068NET and H8300H_H8MAX dependancy for NE_H8300
Date: Tue, 03 Sep 2013 22:37:20 -0400 (EDT)
Message-ID: <20130903.223720.765149153140271341.davem@davemloft.net>
References: <522011A1.2080305@asianux.com>
	<20130830143639.GA16269@windriver.com>
	<5223F5D2.7050504@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, ysato@users.sourceforge.jp,
	keescook@chromium.org, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab3IDCh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:37:28 -0400
In-Reply-To: <5223F5D2.7050504@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Mon, 02 Sep 2013 10:20:02 +0800

> Currently only H8300H_AKI3068NET and H8300H_H8MAX define default
> I/O base and IRQ values for the NE_H8300 driver.  Hence builds
> for other H8300H platforms will fail as per below. Since H8300H
> does not support multi platform builds, we simply limit building
> the driver to those two platforms specifically.
> 
> The release error:
 ...
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Applied, thanks.
