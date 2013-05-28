From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] fec: Control the PHY regulator in suspend/resume
Date: Mon, 27 May 2013 22:30:47 -0700 (PDT)
Message-ID: <20130527.223047.2135277761579838349.davem@davemloft.net>
References: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, kernel@pengutronix.de, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932629Ab3E1Fas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:30:48 -0400
In-Reply-To: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 27 May 2013 10:48:28 -0300

> This series provides support for controlling the PHY regulator in suspend/resume.
> 
> Fabio Estevam (5):
>   fec: Place the phy regulator in the private structure
>   fec: Invert the order of error path sequence
>   fec: Disable the PHY regulator on error and removal
>   fec: Remove irqs first
>   fec: Handle the regulator in suspend/resume

Series applied, thanks.
