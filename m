From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH -next] net: ethernet: davinci_emac: remove redundant
 dev_err call in davinci_emac_probe()
Date: Tue, 2 Jul 2013 10:14:49 +0530
Message-ID: <CA+V-a8sPBrko=ZB+qKHNCNiAg3Z--RBuw8wr-MVixOao19tjAA@mail.gmail.com>
References: <CAPgLHd8L_FW1rJLgBiRdof2irA7cWNchxnAJm+nBP4L46UxWMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	davem@davemloft.net, mugunthanvnm@ti.com, jiri@resnulli.us,
	nsekhar@ti.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:57232 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717Ab3GBEpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 00:45:10 -0400
Received: by mail-we0-f179.google.com with SMTP id w59so3820302wes.24
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 21:45:09 -0700 (PDT)
In-Reply-To: <CAPgLHd8L_FW1rJLgBiRdof2irA7cWNchxnAJm+nBP4L46UxWMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 2, 2013 at 6:27 AM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> There is a error message within devm_ioremap_resource
> already, so remove the dev_err call to avoid redundant
> error message.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Regards,
--Prabhakar Lad
