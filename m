From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] ucc_geth: Fix NULL pointer dereference in
 uec_get_ethtool_stats()
Date: Sun, 30 Aug 2009 21:52:24 -0700 (PDT)
Message-ID: <20090830.215224.203201252.davem@davemloft.net>
References: <20090827173547.GA1580@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, galak@kernel.crashing.org,
	timur@freescale.com, scottwood@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751938AbZHaEwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 00:52:10 -0400
In-Reply-To: <20090827173547.GA1580@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All 5 patches applied to net-next-2.6

I would have liked to have seen at least one powerpc ACK for
patch #2 but these were posted more than a week ago, the
patch looks pretty reasonable, and we can't wait forever for
stuff like this.
