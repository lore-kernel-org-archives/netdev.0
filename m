From: Richard Zhao <linuxzsc@gmail.com>
Subject: Re: [PATCH v2 1/1 net-next] fec: net: put tx to napi poll function to
 fix dead lock
Date: Fri, 1 Mar 2013 16:30:05 +0800
Message-ID: <CANg6MZiQTPkWDBRiZB74nVrj-QY2=Nis36fvhv1Cj+p=jzOstA@mail.gmail.com>
References: <1362109034-25805-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lznuaa@gmail.com, Shawn Guo <shawn.guo@linaro.org>,
	B38611@freescale.com, davem@davemloft.net,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	netdev@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:64220 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab3CAIaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 03:30:08 -0500
Received: by mail-wi0-f176.google.com with SMTP id hm14so8743624wib.15
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 00:30:06 -0800 (PST)
In-Reply-To: <1362109034-25805-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it better to change title prefix to net: fec: ..... ?

Thanks
Richard
