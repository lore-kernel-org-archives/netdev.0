From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/2] af_iucv patches for linux-2.6.31
Date: Thu, 18 Jun 2009 11:19:57 -0700 (PDT)
Message-ID: <20090618.111957.70533925.davem@davemloft.net>
References: <20090618075446.890351000@linux.vnet.ibm.com>
	<20090618.013410.04304670.davem@davemloft.net>
	<1245329094.14954.38.camel@braunu-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ursula.braun@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752541AbZFRSTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 14:19:54 -0400
In-Reply-To: <1245329094.14954.38.camel@braunu-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Thu, 18 Jun 2009 14:44:54 +0200

> sorry, I did a git pull on linux-2.6.git first, and the af_iucv patches
> applied cleanly on my system.

It couldn't have applied to Linus's tree because all the IUCV
bits you submitted to me for 2.6.31 are in his tree and that is
what created the conflicts.
