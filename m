From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] s6gmac: fix error return code in s6gmac_probe()
Date: Fri, 22 Mar 2013 10:24:31 -0400 (EDT)
Message-ID: <20130322.102431.835728980328471659.davem@davemloft.net>
References: <CAPgLHd87mx9eMA1O_Nr9uxtKq=uMvmVW=uzaUPwhcjrAe43eaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim.cromie@gmail.com, gregkh@linuxfoundation.org, jkosina@suse.cz,
	oskar@scara.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932925Ab3CVOYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:24:34 -0400
In-Reply-To: <CAPgLHd87mx9eMA1O_Nr9uxtKq=uMvmVW=uzaUPwhcjrAe43eaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 22 Mar 2013 21:17:47 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
