From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: use a more proper compatible string for MVF
 type device
Date: Wed, 22 May 2013 15:01:16 -0700 (PDT)
Message-ID: <20130522.150116.198661400362762752.davem@davemloft.net>
References: <1368974326-24069-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b35083@freescale.com
To: shawn.guo@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756459Ab3EVWBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 18:01:17 -0400
In-Reply-To: <1368974326-24069-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org>
Date: Sun, 19 May 2013 22:38:46 +0800

> MVF is a family while MVF600 is a particular SoC in the family.  We
> generally prefer to use SoC rather than family name in compatible string
> to define a particular type of fec device.  And this is how fec_dt_ids
> works for all those IMX fec variants.  Let's change mvf to mvf600 to
> have it work in the same way.
> 
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>

Applied, thanks.
