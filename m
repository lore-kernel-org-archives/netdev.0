From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] phy/marvell: fix 88e1121 support
Date: Thu, 21 Oct 2010 04:00:15 -0700 (PDT)
Message-ID: <20101021.040015.27805979.davem@davemloft.net>
References: <4CBCC3FC.2030506@ti.com>
	<20101018222947.418028323@rtp-net.org>
	<20101018223056.716357140@rtp-net.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cyril@ti.com
To: arnaud.patard@rtp-net.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753745Ab0JUK7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:59:53 -0400
In-Reply-To: <20101018223056.716357140@rtp-net.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Date: Tue, 19 Oct 2010 00:29:48 +0200

> Commit c477d0447db08068a497e7beb892b2b2a7bff64b added support for RGMII
> rx/tx delays except that it ends up clearing rx/tx delays bit for modes
> differents that RGMII*ID. Due to this, ethernet is not working anymore
> on my guruplug server +. This patch is fixing that.
> 
> Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>

Applied, thanks.
