From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4vf: Implement "Unhandled Interrupts"
 statistic
Date: Thu, 08 Jul 2010 23:48:55 -0700 (PDT)
Message-ID: <20100708.234855.98876757.davem@davemloft.net>
References: <201007081107.45287.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751375Ab0GIGsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:48:40 -0400
In-Reply-To: <201007081107.45287.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Thu, 8 Jul 2010 11:07:44 -0700

>>From 6c9cc1b5441afb32ecfcd10ac3060452e3c4df6f Mon Sep 17 00:00:00 2001
> From: Casey Leedom <leedom@chelsio.com>
> Date: Thu, 8 Jul 2010 10:05:48 -0700
> Subject: [PATCH net-next] cxgb4vf: Implement "Unhandled Interrupts" statistic
> 
> Implement "Unhandled Interrupts" statistic so we can detect when the
> hardware tells us that it things we have work to do but we don't find
> anything ...
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied, thanks.
