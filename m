From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] EP93XX_ETH must select MII
Date: Mon, 16 Jul 2007 18:29:48 -0400
Message-ID: <469BF15C.90906@garzik.org>
References: <20070713001208.GX3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Donoghue <john.donoghue@ieee.org>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37270 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756174AbXGPW3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 18:29:51 -0400
In-Reply-To: <20070713001208.GX3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> From: John Donoghue <john.donoghue@ieee.org>
> 
> CONFIG_EP93XX_ETH=y, CONFIG_MII=n results in an obvious link error.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


