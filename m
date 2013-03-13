From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tuntap: remove unused variable in __tun_detach()
Date: Wed, 13 Mar 2013 11:33:03 -0400 (EDT)
Message-ID: <20130313.113303.189667361390943742.davem@davemloft.net>
References: <CAPgLHd-v-daRHrDqoencJOTTvxLU_RD44BWzvdHd6j5Qrr8J5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, edumazet@google.com,
	nhorman@tuxdriver.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391Ab3CMPcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 11:32:51 -0400
In-Reply-To: <CAPgLHd-v-daRHrDqoencJOTTvxLU_RD44BWzvdHd6j5Qrr8J5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 13 Mar 2013 21:03:58 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The variable dev is initialized but never used
> otherwise, so remove the unused variable.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
