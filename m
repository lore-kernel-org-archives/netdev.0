From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] tg3: adapt tg3 to use reworked PCI PM code
Date: Wed, 30 Jul 2008 16:38:03 -0700 (PDT)
Message-ID: <20080730.163803.225640986.davem@davemloft.net>
References: <200807301942.m6UJgQfG012742@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, rjw@sisk.pl,
	jbarnes@virtuousgeek.org, shemminger@linux-foundation.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761270AbYG3XiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:38:03 -0400
In-Reply-To: <200807301942.m6UJgQfG012742@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:42:25 -0700

> Adapt the tg3 driver to use the reworked PCI PM and make it use the
> exported PCI PM core functions instead of accessing the PCI PM registers
> directly by itself.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Looks good, applied, thanks.
