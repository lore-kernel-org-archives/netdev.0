From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: add missing .owner to struct pppox_proto
Date: Tue, 02 Jul 2013 01:12:32 -0700 (PDT)
Message-ID: <20130702.011232.79077204542157061.davem@davemloft.net>
References: <CAPgLHd8ehTkW5GwU7o_PYcSN66ovLcooc9kzJvM2P6Na-nDcJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab3GBIMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:12:33 -0400
In-Reply-To: <CAPgLHd8ehTkW5GwU7o_PYcSN66ovLcooc9kzJvM2P6Na-nDcJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 2 Jul 2013 09:02:07 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add missing .owner of struct pppox_proto. This prevents the
> module from being removed from underneath its users.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, and queued up for -stable, thanks.
