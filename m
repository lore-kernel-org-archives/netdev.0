From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xps: Add CONFIG_XPS
Date: Sun, 28 Nov 2010 18:24:25 -0800 (PST)
Message-ID: <20101128.182425.39182533.davem@davemloft.net>
References: <alpine.DEB.2.00.1011261033070.20580@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51771
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754347Ab0K2CX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 21:23:59 -0500
In-Reply-To: <alpine.DEB.2.00.1011261033070.20580@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 26 Nov 2010 10:36:09 -0800 (PST)

> This patch adds XPS_CONFIG option to enable and disable XPS.  This is
> done in the same manner as RPS_CONFIG.  This is also fixes build
> failure in XPS code when SMP is not enabled.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
