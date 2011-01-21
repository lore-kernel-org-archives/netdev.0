From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: fix the WOL bug on 1000M full duplex
 forced mode.
Date: Thu, 20 Jan 2011 16:56:34 -0800 (PST)
Message-ID: <20110120.165634.257520752.davem@davemloft.net>
References: <20110120145933.GC7291@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, DavidLv@viatech.com.cn
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753949Ab1AUA4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:56:00 -0500
In-Reply-To: <20110120145933.GC7291@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 20 Jan 2011 15:59:33 +0100

> The VIA velocity card can't be waken up by WOL tool on 1000M full
> duplex forced mode. This patch fixes the bug.
> 
> Signed-off-by: David Lv <DavidLv@viatech.com.cn>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
