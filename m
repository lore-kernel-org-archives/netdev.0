From: Richard Zhao <richard.zhao@linaro.org>
Subject: Re: [PATCH 1/1] net: fec: convert to clk_prepare/clk_unprepare
Date: Sun, 13 Nov 2011 11:30:17 +0800
Message-ID: <20111113033012.GB2425@richard-laptop>
References: <1320901304-13157-1-git-send-email-richard.zhao@linaro.org>
 <20111111.204326.828073674055146601.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kernel@pengutronix.de, shawn.guo@linaro.org, eric.miao@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:59876 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab1KMDao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 22:30:44 -0500
Received: by iage36 with SMTP id e36so5745136iag.19
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2011 19:30:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111111.204326.828073674055146601.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2011 at 08:43:26PM -0500, David Miller wrote:
> From: Richard Zhao <richard.zhao@linaro.org>
> Date: Thu, 10 Nov 2011 13:01:44 +0800
> 
> > Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> 
> You're going to have to provide a more reasonable commit message.
> 
> Unless it's a typo fix or similar you need to explain your change
> and why it's necessary.

It's for migrating to generic clock framework.
Is it ok if I add above to commit message?

Richard
