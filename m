From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Expand 5719 workaround
Date: Thu, 10 Feb 2011 20:04:38 -0800 (PST)
Message-ID: <20110210.200438.226782994.davem@davemloft.net>
References: <1297389447-5324-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910Ab1BKEED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 23:04:03 -0500
In-Reply-To: <1297389447-5324-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 10 Feb 2011 17:57:27 -0800

> As a precautionary measure, expand the fix submitted in commit
> 4d163b75e979833979cc401ae433cb1d7743d57e entitled "tg3: Fix 5719 A0 tx
> completion bug" to apply to all 5719 revisions.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Applied to net-next-2.6, since that is where this applied cleanly.

If you want this in net-2.6 too, just submit a patch which applies
cleanly there.

Thanks.
