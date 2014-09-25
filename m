From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Thu, 25 Sep 2014 16:43:50 +0200
Message-ID: <20140925144350.GC21453@netboy>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-5-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	b38611@freescale.com, b20596@freescale.com,
	stephen@networkplumber.org
To: Luwei Zhou <b45643@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64893 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470AbaIYOn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 10:43:56 -0400
Received: by mail-wi0-f174.google.com with SMTP id fb4so9099967wid.7
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 07:43:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1411632621-17429-5-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 04:10:21PM +0800, Luwei Zhou wrote:
> This patch update fec devicetree binding doc that add Optional properties
> "pps-channel".

Again, use the PTP pin interface. We don't need a random new FEC DT
property for this.

Thanks,
Richard
