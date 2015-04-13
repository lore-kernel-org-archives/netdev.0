From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/macb: sqe_test_errors are TX errors, not
 RX errors
Date: Sun, 12 Apr 2015 20:43:06 -0400 (EDT)
Message-ID: <20150412.204306.175320556619217303.davem@davemloft.net>
References: <1428658976-28050-1-git-send-email-wsteinwender@pcs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: wsteinwender@pcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbbDMAnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 20:43:08 -0400
In-Reply-To: <1428658976-28050-1-git-send-email-wsteinwender@pcs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Steinwender <wsteinwender@pcs.com>
Date: Fri, 10 Apr 2015 11:42:56 +0200

> The statistics are grouped by TX and RX errors.
> The SQE Test Errors Register indicates problems with TX.
> 
> Signed-off-by: Wolfgang Steinwender <wsteinwender@pcs.com>

Applied, thank you!
