From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: ep7211-sir: Convert to platform_diver
Date: Mon, 03 Dec 2012 13:33:18 -0500 (EST)
Message-ID: <20121203.133318.64671503663114037.davem@davemloft.net>
References: <1354360046-4818-1-git-send-email-shc_work@mail.ru>
	<201212012050.22382.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shc_work@mail.ru, netdev@vger.kernel.org, samuel@sortiz.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545Ab2LCSdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:33:20 -0500
In-Reply-To: <201212012050.22382.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 1 Dec 2012 20:50:22 +0000

> On Saturday 01 December 2012, Alexander Shiyan wrote:
>> This patch converts ep7211-sir driver to platform_driver.
>> Since driver can be used not only for EP7211 CPU, function names
>> was be renamed to generic clps711x...
>> 
>> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Applied.
