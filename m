From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: remove return value from netpoll_rx_disable()
Date: Mon, 27 May 2013 23:19:50 -0700 (PDT)
Message-ID: <20130527.231950.1275379929066214568.davem@davemloft.net>
References: <51A4465B.4010901@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, edumazet@google.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932971Ab3E1GTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:19:50 -0400
In-Reply-To: <51A4465B.4010901@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 28 May 2013 13:53:31 +0800

> The netpoll_rx_disable() will always return 0, it is no use and looks wordy,
> so remove the unnecessary code and get rid of it in _dev_open and _dev_close.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks.
