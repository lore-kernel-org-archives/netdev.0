From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4 v2] net: sh_eth: fix up the buffer pointers
Date: Wed, 27 Jun 2012 01:24:54 -0700 (PDT)
Message-ID: <20120627.012454.376798396628515657.davem@davemloft.net>
References: <4FEAA161.4030001@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422Ab2F0IYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:24:54 -0400
In-Reply-To: <4FEAA161.4030001@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Wed, 27 Jun 2012 15:00:01 +0900

> After freeing the buffer, the driver should change the value of
> the pointer to NULL.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
