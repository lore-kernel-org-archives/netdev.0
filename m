From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7 v2] GRETH: fix opening/closing
Date: Fri, 14 Jan 2011 12:46:29 -0800 (PST)
Message-ID: <20110114.124629.04691834.davem@davemloft.net>
References: <1295010163-2585-1-git-send-email-daniel@gaisler.com>
	<1295010163-2585-2-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: daniel@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080Ab1ANUp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 15:45:57 -0500
In-Reply-To: <1295010163-2585-2-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Fri, 14 Jan 2011 14:02:38 +0100

> When NAPI is disabled there is no point in having IRQs enabled, TX/RX
> should be off before clearing the TX/RX descriptor rings.
> 
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>

Applied.
