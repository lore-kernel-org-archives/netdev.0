From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] sctp: fix error return code in __sctp_connect()
Date: Sun, 07 Apr 2013 17:04:39 -0400 (EDT)
Message-ID: <20130407.170439.70609816272776228.davem@davemloft.net>
References: <CAPgLHd-X5Qw64BnaSMr2ny6==jXGpRAYC7_1MGhP2v_GcVeApQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, sri@us.ibm.com, nhorman@tuxdriver.com,
	yongjun_wei@trendmicro.com.cn, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934357Ab3DGVEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 17:04:41 -0400
In-Reply-To: <CAPgLHd-X5Qw64BnaSMr2ny6==jXGpRAYC7_1MGhP2v_GcVeApQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 3 Apr 2013 21:02:28 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
