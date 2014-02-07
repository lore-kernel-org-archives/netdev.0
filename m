From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: irda: ep7211-sir: Remove driver
Date: Thu, 06 Feb 2014 19:55:07 -0800 (PST)
Message-ID: <20140206.195507.661032642429803808.davem@davemloft.net>
References: <1391528612-16957-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: shc_work@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaBGDzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 22:55:07 -0500
In-Reply-To: <1391528612-16957-1-git-send-email-shc_work@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Shiyan <shc_work@mail.ru>
Date: Tue,  4 Feb 2014 19:43:32 +0400

> This patch removes old and unsupported CLPS711X IrDA driver.
> Support for IrDA for CLPS711X serial port now provided by commit
> 4a33f1f59abd (serial: clps711x: Add support for N_IRDA line
> discipline), so IrDA-mode can be turned ON with "irattach" tool
> through "irtty" driver.
> 
> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>

Applied, thanks.
