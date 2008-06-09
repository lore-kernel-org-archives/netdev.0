From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/3] iucv / af_iucv patches for net-2.6.26
Date: Mon, 09 Jun 2008 15:52:19 -0700 (PDT)
Message-ID: <20080609.155219.105101380.davem@davemloft.net>
References: <20080605090837.212105000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: braunu@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54967
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751780AbYFIWwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 18:52:20 -0400
In-Reply-To: <20080605090837.212105000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>
Date: Thu, 05 Jun 2008 11:08:37 +0200

> the following 3 small patches are intended for 2.6.26.
> They are built against git/davem/net-2.6.26
> They contain:
> iucv:    remove WARNING              (from Heiko Carstens)
> iucv:    cpu hotplug fix             (from Heiko Carstens)
> af_iucv: exploit message class field (from Ursula Braun)

All applied and pushed out to net-2.6.26, thanks!
