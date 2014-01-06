From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Revert "fec: Do not assume that PHY reset is
 active low"
Date: Sun, 05 Jan 2014 20:24:40 -0500 (EST)
Message-ID: <20140105.202440.1690703258987846842.davem@davemloft.net>
References: <1388966905-8092-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, olof@lixom.net, linux@arm.linux.org.uk,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaAFBYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 20:24:42 -0500
In-Reply-To: <1388966905-8092-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Sun,  5 Jan 2014 22:08:25 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> In order to keep DT compatibility we need to revert this, otherwise the original
> dts files will no longer work with this driver change.
> 
> This reverts commit 7a399e3a2e05bc580a78ea72371b3896827f72e1.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
