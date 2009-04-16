From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/12] fec: refactor init function
Date: Thu, 16 Apr 2009 02:37:21 -0700 (PDT)
Message-ID: <20090416.023721.110213298.davem@davemloft.net>
References: <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
	<1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
	<1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@snapgear.com
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51674
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753375AbZDPJha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:37:30 -0400
In-Reply-To: <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 15 Apr 2009 13:32:20 +0200

> fec_enet_init() does the hardware initialisation and then calls
> fec_restart() which does the same initialisation again, so we
> can safely remove the initialisation from fec_enet_init().
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Applied.
