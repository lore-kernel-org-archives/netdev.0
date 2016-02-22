From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fmvj18x_cs: fix incorrect indexing of dev->dev_addr[]
 when copying the MAC address
Date: Sun, 21 Feb 2016 22:09:18 -0500 (EST)
Message-ID: <20160221.220918.1954869190057677226.davem@davemloft.net>
References: <20160220191436.346fd0e6c63db659ea6582b9@nifty.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@nifty.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbcBVDJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 22:09:20 -0500
In-Reply-To: <20160220191436.346fd0e6c63db659ea6582b9@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@nifty.com>
Date: Sat, 20 Feb 2016 19:14:36 +0900

> fix incorrect indexing of dev->dev_addr[] when copying the MAC address 
> of FMV-J182 at buf[5].
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@nifty.com>

Applied, thanks.
