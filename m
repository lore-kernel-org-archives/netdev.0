From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Wed, 09 Jun 2010 16:17:25 -0700 (PDT)
Message-ID: <20100609.161725.71104620.davem@davemloft.net>
References: <20100605140017.GA2750@riccoc20.at.omicron.at>
	<20100607.011835.55846752.davem@davemloft.net>
	<20100607153932.GA2800@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33601
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752222Ab0FIXRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 19:17:14 -0400
In-Reply-To: <20100607153932.GA2800@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 7 Jun 2010 17:39:32 +0200

> This patch implements a work around for Erratum 5, "3.3 V Fiber Speed
> Selection." If the hardware wiring does not respect this erratum, then
> fiber optic mode will not work properly.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Applied, thanks.
