From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] esp4: fix error return code in esp_output()
Date: Mon, 15 Apr 2013 14:06:15 -0400 (EDT)
Message-ID: <20130415.140615.854934131029854117.davem@davemloft.net>
References: <CAPgLHd9zivXBfC5DvuKwr+C3vX+-kJjqSrLRRyAvk=nmBvGaaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504Ab3DOSGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:06:20 -0400
In-Reply-To: <CAPgLHd9zivXBfC5DvuKwr+C3vX+-kJjqSrLRRyAvk=nmBvGaaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sun, 14 Apr 2013 09:49:03 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
