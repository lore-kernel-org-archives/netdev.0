From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] bna: Staticize local functions
Date: Mon, 05 Aug 2013 11:10:07 -0700 (PDT)
Message-ID: <20130805.111007.1507887255078255550.davem@davemloft.net>
References: <002001ce91ba$2d4b7eb0$87e27c10$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab3HESKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 14:10:08 -0400
In-Reply-To: <002001ce91ba$2d4b7eb0$87e27c10$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 05 Aug 2013 18:00:04 +0900

> bna_rx_sm_stop_wait_entry(), bna_rx_sm_rxf_stop_wait_entry(),
> bna_rx_sm_started_entry(), bna_rx_sm_cleanup_wait_entry(),
> and bna_rx_sm_cleanup_wait() are used only in this file.
> Fix the following sparse warnings:
 ...
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
