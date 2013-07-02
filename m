From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: davinci_emac: remove redundant
 dev_err call in davinci_emac_probe()
Date: Tue, 02 Jul 2013 01:10:32 -0700 (PDT)
Message-ID: <20130702.011032.1180173730234333060.davem@davemloft.net>
References: <CAPgLHd8L_FW1rJLgBiRdof2irA7cWNchxnAJm+nBP4L46UxWMA@mail.gmail.com>
	<51D2630B.9010600@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, grant.likely@linaro.org,
	rob.herring@calxeda.com, prabhakar.csengg@gmail.com,
	jiri@resnulli.us, nsekhar@ti.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab3GBIKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:10:33 -0400
In-Reply-To: <51D2630B.9010600@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 2 Jul 2013 10:50:11 +0530

> On Tuesday 02 July 2013 06:27 AM, Wei Yongjun wrote:
>> From: Wei Yongjun<yongjun_wei@trendmicro.com.cn>
>>
>> There is a error message within devm_ioremap_resource
>> already, so remove the dev_err call to avoid redundant
>> error message.
>>
>> Signed-off-by: Wei Yongjun<yongjun_wei@trendmicro.com.cn>
> 
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks everyone.
