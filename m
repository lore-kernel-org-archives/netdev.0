From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ETHOC: fix build breakage on s390
Date: Tue, 31 Mar 2009 14:41:18 -0700 (PDT)
Message-ID: <20090331.144118.07019379.davem@davemloft.net>
References: <20090330113015.21576898@osiris.boeblingen.de.ibm.com>
	<20090330115202.GA13719@avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org
To: thierry.reding@avionic-design.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51931
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751022AbZCaVl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 17:41:29 -0400
In-Reply-To: <20090330115202.GA13719@avionic-design.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <thierry.reding@avionic-design.de>
Date: Mon, 30 Mar 2009 13:52:02 +0200

> * Heiko Carstens wrote:
> > From: Heiko Carstens <heiko.carstens@de.ibm.com>
> > 
> > Let driver depend on HAS_IOMEM to avoid build breakage on s390:
> > 
> >   CC      drivers/net/ethoc.o
> > drivers/net/ethoc.c: In function 'ethoc_read':
 ...
> > Cc: Thierry Reding <thierry.reding@avionic-design.de>
> > Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
 ...
> Acked-by: Thierry Reding <thierry.reding@avionic-design.de>

Applied.
