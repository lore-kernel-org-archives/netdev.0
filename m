From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/12] fec: call fec_restart() in fec_open()
Date: Thu, 16 Apr 2009 02:38:15 -0700 (PDT)
Message-ID: <20090416.023815.182500497.davem@davemloft.net>
References: <1239795145-27558-11-git-send-email-s.hauer@pengutronix.de>
	<1239795145-27558-12-git-send-email-s.hauer@pengutronix.de>
	<1239795145-27558-13-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@snapgear.com
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753850AbZDPJiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:38:24 -0400
In-Reply-To: <1239795145-27558-13-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 15 Apr 2009 13:32:25 +0200

> We called fec_stop() in fec_enet_close(), thus we have to call
> fec_restart() in fec_enet_open().
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Applied.
