From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lan78xx: Return 0 when lan78xx_suspend() has
 no error.
Date: Mon, 28 Sep 2015 22:29:18 -0700 (PDT)
Message-ID: <20150928.222918.819971433540165698.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D40423528@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbbI2F3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:29:20 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40423528@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Fri, 25 Sep 2015 21:13:48 +0000

> lan78xx_suspend() may return non-zero from lan78xx_write_reg() in some scenario.
> Fix to return 0 when lan78xx_suspend() has no error.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied, thanks.
