From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ibmveth: Add suspend/resume support
Date: Mon, 22 Feb 2010 15:46:56 -0800 (PST)
Message-ID: <20100222.154656.35535481.davem@davemloft.net>
References: <201002211647.o1LGlqh3023138@d01av01.pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47074
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751867Ab0BVXqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:46:38 -0500
In-Reply-To: <201002211647.o1LGlqh3023138@d01av01.pok.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>
Date: Sun, 21 Feb 2010 10:48:01 -0600

> 
> Adds support for resuming from suspend for IBM virtual ethernet devices.
> We may have lost an interrupt over the suspend, so we just kick the
> interrupt handler to process anything that is outstanding.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>

Applied.
