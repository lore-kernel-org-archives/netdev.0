From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] qlge: minor fixes.
Date: Wed, 17 Feb 2010 13:42:54 -0800 (PST)
Message-ID: <20100217.134254.04460767.davem@davemloft.net>
References: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57266
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757363Ab0BQVmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:42:39 -0500
In-Reply-To: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 17 Feb 2010 08:41:20 -0800

> 
>  Miscellaneous fixes for qlge:
> 
> 1) Fix large ping (non-TCP/UDP) frame dropping when data spans
> multiple  rx  buffers.
> 2) Fix mac address filter issue for bonding.
> 3) Fix ethtool loopback test.

All applied, thanks.
