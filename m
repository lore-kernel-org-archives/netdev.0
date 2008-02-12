From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] race in generic address resolution
Date: Mon, 11 Feb 2008 21:47:11 -0800 (PST)
Message-ID: <20080211.214711.134366517.davem@davemloft.net>
References: <20080204142717.GA11020@tuxmaker.boeblingen.de.ibm.com>
	<20080205.205154.153345843.davem@davemloft.net>
	<47B00EE0.4040109@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50598
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752882AbYBLFql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 00:46:41 -0500
In-Reply-To: <47B00EE0.4040109@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Mon, 11 Feb 2008 10:01:20 +0100

> we run your patch during the weekend on single CPU and SMP
> machines. We do not see any problems. Thanks for providing the fix.

Thanks for testing Frank, I can now push this fix upstream.
