From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 12/14 v2] usb/net: rndis: merge command codes
Date: Wed, 25 Apr 2012 20:39:31 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD36CCA@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1335368163-4792-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>
To: Linus Walleij <linus.walleij@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:1466 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758815Ab2DYUjv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 16:39:51 -0400
In-Reply-To: <1335368163-4792-1-git-send-email-linus.walleij@linaro.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Linus Walleij [mailto:linus.walleij@linaro.org]
> Sent: Wednesday, April 25, 2012 11:36 AM
> To: netdev@vger.kernel.org; linux-usb@vger.kernel.org; Greg Kroah-Hartman;
> David S. Miller; Felipe Balbi
> Cc: Jussi Kivilinna; Haiyang Zhang; Wei Yongjun; Ben Hutchings; Linus
> Walleij
> Subject: [PATCH 12/14 v2] usb/net: rndis: merge command codes
> 
> Switch the hyperv filter and rndis gadget driver to use the same command
> enumerators as the other drivers and delete the surplus command codes.
> 
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
>  drivers/net/hyperv/rndis_filter.c |   42 ++++++++++++++++++--------------
> ----
>  drivers/usb/gadget/rndis.c        |   37 +++++++++++++++----------------
>  include/linux/rndis.h             |   17 ---------------
>  3 files changed, 39 insertions(+), 57 deletions(-)
> 

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
