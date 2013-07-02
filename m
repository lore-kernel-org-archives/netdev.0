From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH -next] net: ethernet: davinci_emac: remove redundant dev_err
 call in davinci_emac_probe()
Date: Tue, 2 Jul 2013 10:50:11 +0530
Message-ID: <51D2630B.9010600@ti.com>
References: <CAPgLHd8L_FW1rJLgBiRdof2irA7cWNchxnAJm+nBP4L46UxWMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <grant.likely@linaro.org>, <rob.herring@calxeda.com>,
	<davem@davemloft.net>, <prabhakar.csengg@gmail.com>,
	<jiri@resnulli.us>, <nsekhar@ti.com>,
	<yongjun_wei@trendmicro.com.cn>, <netdev@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:43538 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488Ab3GBFSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 01:18:44 -0400
In-Reply-To: <CAPgLHd8L_FW1rJLgBiRdof2irA7cWNchxnAJm+nBP4L46UxWMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 02 July 2013 06:27 AM, Wei Yongjun wrote:
> From: Wei Yongjun<yongjun_wei@trendmicro.com.cn>
>
> There is a error message within devm_ioremap_resource
> already, so remove the dev_err call to avoid redundant
> error message.
>
> Signed-off-by: Wei Yongjun<yongjun_wei@trendmicro.com.cn>

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
