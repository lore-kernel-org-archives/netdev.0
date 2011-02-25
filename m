From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] dccp: newdp is declared/assigned but never be used
Date: Fri, 25 Feb 2011 14:00:39 -0800 (PST)
Message-ID: <20110225.140039.70214278.davem@davemloft.net>
References: <1298648721-3026-1-git-send-email-hagen@jauu.net>
	<1298648721-3026-2-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46775
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754912Ab1BYWAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 17:00:03 -0500
In-Reply-To: <1298648721-3026-2-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Fri, 25 Feb 2011 16:45:16 +0100

> Declaration and assignment of newdp is removed. Usage of dccp_sk()
> exhibit no side effects.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied to net-next-2.6
