From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: replace DPRINTK() with pr_debug
Date: Fri, 24 Aug 2007 22:37:13 -0700 (PDT)
Message-ID: <20070824.223713.49250188.davem@davemloft.net>
References: <20070817183131.05c3a9fb@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50037
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751301AbXHYFhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 01:37:14 -0400
In-Reply-To: <20070817183131.05c3a9fb@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 17 Aug 2007 18:31:31 -0700

> Get rid of using DPRINTK macro in ATM and use pr_debug (in kernel.h).
> Using the standard macro is cleaner and forces code to check for bad arguments
> and formatting.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.24, thanks Stephen.
