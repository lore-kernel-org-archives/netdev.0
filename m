From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [BRIDGE] Remove unused include of a header
 file in ebtables.c
Date: Fri, 18 Jan 2008 05:38:42 -0800 (PST)
Message-ID: <20080118.053842.125066268.davem@davemloft.net>
References: <eb3ff54b0801180508k7d24855ft2747224f0fb1725f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754561AbYARNil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 08:38:41 -0500
In-Reply-To: <eb3ff54b0801180508k7d24855ft2747224f0fb1725f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Fri, 18 Jan 2008 15:08:02 +0200

> In net/bridge/netfilter/ebtables.c,
> - remove unused include of a header file (linux/tty.h) and remove the
>   corresponding comment above it.
> 	
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
