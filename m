From: David Miller <davem@davemloft.net>
Subject: BNX2 warning
Date: Thu, 20 Dec 2007 20:39:35 -0800 (PST)
Message-ID: <20071220.203935.30925934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36637
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754573AbXLUEjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:39:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ misspelled netdev list first time, retrying... ]

Michael, please fix this, thanks :-)

drivers/net/bnx2.c: In function 'bnx2_init_napi':
drivers/net/bnx2.c:7329: warning: no return statement in function returning non-void
