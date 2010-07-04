From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] bnx2: Dump some config space registers
 during TX timeout.
Date: Sun, 04 Jul 2010 11:44:44 -0700 (PDT)
Message-ID: <20100704.114444.59684529.davem@davemloft.net>
References: <1278225738-7795-1-git-send-email-mchan@broadcom.com>
	<1278225738-7795-2-git-send-email-mchan@broadcom.com>
	<1278225738-7795-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36865
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757884Ab0GDSob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jul 2010 14:44:31 -0400
In-Reply-To: <1278225738-7795-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 3 Jul 2010 23:42:17 -0700

> These config register values will be useful when the memory registers
> are returning 0xffffffff which has been reported.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
