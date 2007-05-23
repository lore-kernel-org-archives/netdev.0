From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/8] use mutex instead of binary semaphore in idt77252
 driver
Date: Wed, 23 May 2007 14:45:55 -0700 (PDT)
Message-ID: <20070523.144555.108118833.davem@davemloft.net>
References: <200705232135.l4NLZmMh000648@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matthias.kaehlcke@gmail.com,
	chas@cmf.nrl.navy.mil
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56472
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754980AbXEWVpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:45:52 -0400
In-Reply-To: <200705232135.l4NLZmMh000648@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Wed, 23 May 2007 14:35:48 -0700

> From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
> 
> Use mutex instead of binary semaphore in idt77252 driver.
> 
> Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
> Cc: chas williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
