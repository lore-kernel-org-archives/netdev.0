From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/2] net: fec: default select FEC_PTP at mx6 platform
Date: Wed, 7 Nov 2012 09:32:30 +0100
Message-ID: <20121107083230.GA2267@netboy.at.omicron.at>
References: <1352268883-16800-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznuaa@gmail.com, shawn.guo@linaro.org,
	linux-arm-kernel@lists.infradead.or, netdev@vger.kernel.org,
	davem@davemloft.net, bhutchings@solarflare.com
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54704 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307Ab2KGIcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 03:32:41 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so741340eek.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 00:32:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1352268883-16800-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 07, 2012 at 02:14:43PM +0800, Frank Li wrote:
> Remove PPS.
> Limit FEC_PTP option for i.MX chip only.
> FEC_PTP default is on at mx6 platform.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
