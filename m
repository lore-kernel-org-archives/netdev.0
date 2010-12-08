From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] via-rhine: hardware VLAN support
Date: Wed, 08 Dec 2010 10:24:12 -0800 (PST)
Message-ID: <20101208.102412.39180573.davem@davemloft.net>
References: <20101206105940.GA17817@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: rl@hellgate.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756065Ab0LHSXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:23:45 -0500
In-Reply-To: <20101206105940.GA17817@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roger Luethi <rl@hellgate.ch>
Date: Mon, 6 Dec 2010 11:59:40 +0100

> This patch adds VLAN hardware support for Rhine chips.
> 
> The driver uses up to 3 additional bytes of buffer space when extracting
> 802.1Q headers; PKT_BUF_SZ should still be sufficient.
> 
> The initial code was provided by David Lv. I reworked it to use standard
> kernel facilities. Coding style clean up mostly follows via-velocity.
> 
> Adapted to new interface for VLAN acceleration (per request of Jesse Gross).
> 
> Signed-off-by: David Lv <DavidLv@viatech.com.cn>
> Signed-off-by: Roger Luethi <rl@hellgate.ch>

Applied, thanks a lot Roger.
