From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] via-velocity: S3 resume fix.
Date: Sun, 05 Feb 2012 17:47:54 -0500 (EST)
Message-ID: <20120205.174754.2243394389352770519.davem@davemloft.net>
References: <20120205092226.GB18774@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, DavidLv@viatech.com.cn
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204Ab2BEWs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 17:48:58 -0500
In-Reply-To: <20120205092226.GB18774@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 5 Feb 2012 10:22:26 +0100

> From: David Lv <DavidLv@viatech.com.cn>
> 
> Initially diagnosed on Ubuntu 11.04 with kernel 2.6.38.
> 
> velocity_close is not called during a suspend / resume cycle in this
> driver and it has no business playing directly with power states.
> 
> Signed-off-by: David Lv <DavidLv@viatech.com.cn>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied and queued up for -stable, thanks.
