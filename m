From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] doc: dt: fsl: fec: add napi optional
 properties
Date: Thu, 24 Jan 2013 18:18:00 -0500 (EST)
Message-ID: <20130124.181800.580308569081621879.davem@davemloft.net>
References: <1359011219-8343-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071Ab3AXXSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 18:18:05 -0500
In-Reply-To: <1359011219-8343-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Thu, 24 Jan 2013 15:06:59 +0800

> Signed-off-by: Frank Li <Frank.Li@freescale.com>

For the thousandth time, you should not make NAPI run time
selectable, this is non-negotable.
