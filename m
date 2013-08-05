From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: Pack dst_cookie into 1st cacheline hole
 for 64bit host
Date: Mon, 05 Aug 2013 12:21:06 -0700 (PDT)
Message-ID: <20130805.122106.42978925856402117.davem@davemloft.net>
References: <1375693983-22824-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613Ab3HETVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 15:21:07 -0400
In-Reply-To: <1375693983-22824-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Mon, 5 Aug 2013 17:13:03 +0800

> As dst_cookie is used in fast path sctp_transport_dst_check.
 ...
> Signed-off-by: Fan Du <fan.du@windriver.com>

Applied.
