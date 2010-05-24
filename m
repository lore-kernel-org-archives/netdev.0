From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda: bfin_sir: IRDA is not affected by anomaly
 05000230
Date: Sun, 23 May 2010 23:54:15 -0700 (PDT)
Message-ID: <20100523.235415.16641308.davem@davemloft.net>
References: <1274601610-882-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	graf.yang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753654Ab0EXGyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:54:06 -0400
In-Reply-To: <1274601610-882-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Sun, 23 May 2010 04:00:10 -0400

> From: Graf Yang <graf.yang@analog.com>
> 
> Anomaly 05000230 (over sampling of the UART STOP bit) applies only when
> the peripheral is operating in UART mode.  So drop the anomaly handling
> in the IRDA code.
> 
> Signed-off-by: Graf Yang <graf.yang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied, thanks.
