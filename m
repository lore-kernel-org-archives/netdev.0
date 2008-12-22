From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] tg3: Cleanup IPV6 LSO
Date: Sun, 21 Dec 2008 20:22:20 -0800 (PST)
Message-ID: <20081221.202220.223953698.davem@davemloft.net>
References: <1229717359.5499@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752922AbYLVEWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 23:22:17 -0500
In-Reply-To: <1229717359.5499@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 17 Dec 2008 18:15:06 -0800

> This patch attempts to make the relationship between IPV6 checksum
> offload and IPV6 LSO more obvious.  The patch also toggles a bit
> needed for IPV6 LSO on 5785 and 57780 devices.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
