From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] broadcom: Fix &&/|| confusion in
 bcm54xx_adjust_rxrefclk()
Date: Sun, 03 Jan 2010 22:01:54 -0800 (PST)
Message-ID: <20100103.220154.226474085.davem@davemloft.net>
References: <4B3B831A.507@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, mcarlson@broadcom.com
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751487Ab0ADGBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 01:01:51 -0500
In-Reply-To: <4B3B831A.507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 30 Dec 2009 17:43:06 +0100

> This always evaluates to true.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks Roel.
