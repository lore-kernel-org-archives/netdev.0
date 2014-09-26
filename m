From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 2/4] net: fec: ptp: Use hardware algorithm to adjust
 PTP counter.
Date: Fri, 26 Sep 2014 10:22:46 +0200
Message-ID: <20140926082245.GA4575@netboy>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-3-git-send-email-b45643@freescale.com>
 <20140925142923.GA21453@netboy>
 <cd5a482f0db446f9adce6906b19a9c56@BY2PR03MB441.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:35155 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358AbaIZIWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 04:22:53 -0400
Received: by mail-la0-f54.google.com with SMTP id ty20so1479498lab.41
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 01:22:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cd5a482f0db446f9adce6906b19a9c56@BY2PR03MB441.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 05:53:41AM +0000, luwei.zhou@freescale.com wrote:

> [Zhou Luwei-B45643] Thanks. It can pass compile without warning and
> test. In fact I used other tools to increase SYNC rate to 16 per
> second and it works well.

Some PTP profiles use 128 per second.

Thanks,
Richard
