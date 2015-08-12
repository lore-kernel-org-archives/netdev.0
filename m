From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: atl1c: add BQL support
Date: Wed, 12 Aug 2015 16:27:53 -0700 (PDT)
Message-ID: <20150812.162753.1923612975590939443.davem@davemloft.net>
References: <55CAE130.8040406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ronangeles@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbbHLX2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 19:28:00 -0400
In-Reply-To: <55CAE130.8040406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Angeles <ronangeles@gmail.com>
Date: Tue, 11 Aug 2015 23:01:20 -0700

> This BQL implementation is mostly derived from its related driver, alx.
> Tested on AR8131 (rev c0) [1969:1063]. Saturated a 100mbps link with 5
> concurrent runs of netperf. Ping latency dropped from 14ms to 3ms.
> 
> Signed-off-by: Ron Angeles <ronangeles@gmail.com>

Applied, thanks.
