From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: fix wait-bit inversion.
Date: Sun, 01 Apr 2012 23:10:44 -0400 (EDT)
Message-ID: <20120401.231044.2143460898946854493.davem@davemloft.net>
References: <20120401223500.GA28138@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andi@lisas.de, DavidLv@viatech.com.cn
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531Ab2DBDLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:11:53 -0400
In-Reply-To: <20120401223500.GA28138@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 2 Apr 2012 00:35:00 +0200

> From: Andreas Mohr <andi@lisas.de>
> 
> Bug appeared in a384a33bb1c9ec2d99db2046b41f57023fa7d77b
> ("via-rhine: RHINE_WAIT_FOR macro removal). It can be noticed
> during suspend/resume.
> 
> Signed-off-by: Andreas Mohr <andi@lisas.de>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: David Lv <DavidLv@viatech.com.cn>

Applied and queued up for -stable, thanks.
