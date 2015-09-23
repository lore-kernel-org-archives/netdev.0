From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] 8139cp: Improve accuracy of cp_interrupt() return,
 to survive IRQ storms
Date: Wed, 23 Sep 2015 10:58:12 -0700 (PDT)
Message-ID: <20150923.105812.149257816141624869.davem@davemloft.net>
References: <1442844109.7367.5.camel@infradead.org>
	<20150922.164522.1769837358584981735.davem@davemloft.net>
	<1442996049.36485.32.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003AbbIWR6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 13:58:16 -0400
In-Reply-To: <1442996049.36485.32.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 23 Sep 2015 09:14:09 +0100

> But sure, for now I'll drop this from the series and I can try to
> convince you separately.

Yes, let's discuss this independantly to the nice bug fixing
that's happening in the rest of this series.

Thanks.
