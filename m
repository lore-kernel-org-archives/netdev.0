From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethernet: qualcomm: use spi instead of
 spi_device
Date: Sun, 10 May 2015 17:53:43 -0400 (EDT)
Message-ID: <20150510.175343.1962085087540222405.davem@davemloft.net>
References: <1430970468-4636-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbbEJVxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 17:53:45 -0400
In-Reply-To: <1430970468-4636-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkabhadram@gmail.com>
Date: Thu,  7 May 2015 09:17:48 +0530

> All spi based drivers have an instance of struct spi_device
> as spi. This patch renames spi_device to spi to synchronize
> with all the drivers.
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

Applied, thank you.
