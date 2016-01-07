From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lan78xx: Fix to write to OTP(One Time
 Programmable) per magic number.
Date: Thu, 07 Jan 2016 16:40:03 -0500 (EST)
Message-ID: <20160107.164003.2012412469151836087.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D4049271B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbcAGVkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 16:40:05 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4049271B@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Tue, 5 Jan 2016 17:29:59 +0000

> This patch fixes a bug writing to EEPROM in lan78xx_ethtool_set_eeprom()
> when asked to write to OTP.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied, thank you.
