From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: add support for PHY interface platform data
Date: Mon, 24 May 2010 00:36:23 -0700 (PDT)
Message-ID: <20100524.003623.04675713.davem@davemloft.net>
References: <20100523.233224.186495044.davem@davemloft.net>
	<3fdc6da7f1b53fdea0e056d47d828e106c4e76c8.1274686230.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45874
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756036Ab0EXHgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 03:36:14 -0400
In-Reply-To: <3fdc6da7f1b53fdea0e056d47d828e106c4e76c8.1274686230.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Mon, 24 May 2010 10:31:05 +0300

> The i.MX25 PDK uses RMII to communicate with its PHY. This patch adds the
> ability to configure RMII, based on platform data.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> Acked-by:  Greg Ungerer <gerg@uclinux.org>

Applied, thanks.
