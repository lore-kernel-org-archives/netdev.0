From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] MCS7830 USB-Ether: add Rx error support
Date: Wed, 03 Feb 2010 18:29:28 -0800 (PST)
Message-ID: <20100203.182928.161624514.davem@davemloft.net>
References: <20100131125819.GA13435@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, dhollis@davehollis.com, pchang23@sbcglobal.net,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59434
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756044Ab0BDC3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 21:29:15 -0500
In-Reply-To: <20100131125819.GA13435@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andi@lisas.de>
Date: Sun, 31 Jan 2010 13:58:19 +0100

> ChangeLog:
> - evaluate Rx error statistics from trailing Rx status byte
> - add driver TODO list
> - add myself to authors
> 
> 
> Quilt series run-tested, based on 2.6.33-rc4 (net-2.6.git mcs7830 has idle history,
> should be good to go).
> 
> Signed-off-by: Andreas Mohr <andi@lisas.de>

Applied to net-next-2.6
