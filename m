From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/7] network driver fixes
Date: Fri, 29 Jan 2016 20:34:16 -0800 (PST)
Message-ID: <20160129.203416.1451706111708529250.davem@davemloft.net>
References: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbcA3EeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 23:34:17 -0500
In-Reply-To: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 29 Jan 2016 12:39:08 +0100

> This is an updated series of fixes for the network device drivers
> that showed warnings in ARM randconfig.
> 
> Changes since v1 are:
> 
> dropped "net: macb: avoid uninitialized variables", already fixed in net-next
> 
> dropped "net: fddi/defxx: avoid warning about uninitialized variable
> 	use", already fixed in net-next
> 
> added missing barriers in "net: moxart: use correct accessors for
> 	DMA memory"
> 
> clarified "net: bgmac: clarify CONFIG_BCMA dependency" changelog

Series applied, thanks.
