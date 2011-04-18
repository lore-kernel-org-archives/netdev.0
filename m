From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dm9000: Fix build
Date: Mon, 18 Apr 2011 14:19:47 -0700 (PDT)
Message-ID: <20110418.141947.98901081.davem@davemloft.net>
References: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	patches@opensource.wolfsonmicro.com
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752495Ab1DRVUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 17:20:22 -0400
In-Reply-To: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Mon, 18 Apr 2011 12:04:37 +0100

> Commit c88fcb (net: dm9000: convert to hw_features) broke the build of
> the dm9000 driver since it merged functions which use different names
> for the board info structure used for I/O operations without updating
> all the references to use the same name. Fix that.
> 
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Applied, thanks.
