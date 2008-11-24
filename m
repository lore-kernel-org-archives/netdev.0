From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139too: use err.h macros
Date: Mon, 24 Nov 2008 14:47:10 -0800 (PST)
Message-ID: <20081124.144710.28080218.davem@davemloft.net>
References: <20081123102237.42cc99dd@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46714
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753309AbYKXWrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 17:47:10 -0500
In-Reply-To: <20081123102237.42cc99dd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sun, 23 Nov 2008 10:22:37 -0800

> Instead of using call by reference use the PTR_ERR macros to handle
> return value with error case. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
