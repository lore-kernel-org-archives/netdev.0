From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] gianfar, ucc_geth: Use proper address
 translation for MDIO buses
Date: Wed, 18 Mar 2009 23:48:57 -0700 (PDT)
Message-ID: <20090318.234857.225870884.davem@davemloft.net>
References: <20090318192152.GA29621@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, scottwood@freescale.com,
	afleming@freescale.com, leoli@freescale.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757705AbZCSGtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 02:49:10 -0400
In-Reply-To: <20090318192152.GA29621@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Wed, 18 Mar 2009 22:21:52 +0300

> David, I believe Kumar would like to pick this patch into his tree
> along with a patch set that adds "ranges = <>" properties to the
> device tree... So would you mind if we take it via powerpc.git?

No problem, and feel free to add my ack:

Acked-by: David S. Miller <davem@davemloft.net>
