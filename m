From: David Miller <davem@davemloft.net>
Subject: Re: [patch 17/28] drivers/atm/iphase.c: mostly kmalloc + memset
 conversion to kzalloc
Date: Fri, 10 Aug 2007 15:26:32 -0700 (PDT)
Message-ID: <20070810.152632.124266823.davem@davemloft.net>
References: <200708102112.l7ALC1UV009424@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, m.kozlowski@tuxland.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755940AbXHJW0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:26:31 -0400
In-Reply-To: <200708102112.l7ALC1UV009424@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:01 -0700

> From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/atm/iphase.c | 111508 -> 111431 (-77 bytes)
>  drivers/atm/iphase.o | 254740 -> 254260 (-480 bytes)
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6, thanks!
