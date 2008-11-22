From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] tg3: Qualify use of tp->pcix_cap
Date: Fri, 21 Nov 2008 17:17:30 -0800 (PST)
Message-ID: <20081121.171730.38023559.davem@davemloft.net>
References: <1227295575.5614@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57956
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752977AbYKVBRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:17:31 -0500
In-Reply-To: <1227295575.5614@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 21 Nov 2008 11:00:04 -0800

> This patch makes sure the device is a PCIX device before attempting to
> use the pcix_cap device structure member.  This is prep work for the
> following patch.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
