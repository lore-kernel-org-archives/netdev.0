From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/12] fec: remove debugging printks
Date: Thu, 16 Apr 2009 02:37:37 -0700 (PDT)
Message-ID: <20090416.023737.04910761.davem@davemloft.net>
References: <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
	<1239795145-27558-9-git-send-email-s.hauer@pengutronix.de>
	<1239795145-27558-10-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@snapgear.com
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51682
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752989AbZDPJhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:37:45 -0400
In-Reply-To: <1239795145-27558-10-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 15 Apr 2009 13:32:22 +0200

> These printks in fec_timeout do not give useful information in
> a production kernel.
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Applied.
