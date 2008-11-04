From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/15] tg3: Move phylib report to end of tg3_init_one
Date: Mon, 03 Nov 2008 16:53:02 -0800 (PST)
Message-ID: <20081103.165302.263789535.davem@davemloft.net>
References: <1225751623.6184@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38265
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754171AbYKDAx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:53:27 -0500
In-Reply-To: <1225751623.6184@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 3 Nov 2008 02:12:47 -0800

> Currently, phylib reports appear with a eth%d prefix.  Move the line
> after register_netdev() and place it alongside the other informative
> messages.  Update nearby informative messages accordingly.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
