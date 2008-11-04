From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/15] tg3: Reclaim TG3_FLG3_5761_5784_AX_FIXES flag
Date: Mon, 03 Nov 2008 16:52:15 -0800 (PST)
Message-ID: <20081103.165215.165191118.davem@davemloft.net>
References: <1225751621.6178@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38256
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753128AbYKDAwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:52:40 -0500
In-Reply-To: <1225751621.6178@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 3 Nov 2008 02:11:42 -0800

> This patch reclaims the TG3_FLG3_5761_5784_AX_FIXES flag.  It only
> used twice in non-fast paths.  This patch also consolidates some other
> places where specific 5784 AX chip revisions can be generalized.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
