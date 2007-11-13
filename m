From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/13] tg3: Add A1 revs
Date: Mon, 12 Nov 2007 21:22:16 -0800 (PST)
Message-ID: <20071112.212216.253107821.davem@davemloft.net>
References: <1194655144.5745.273.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751760AbXKMFWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:22:16 -0500
In-Reply-To: <1194655144.5745.273.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:39:04 -0800

> This patch adds the A1 revision of 5784, 5764, and 5761, and applies all
> previous bugfixes.  In places where the list of devices gets too long,
> the patch uses a new TG3_FLG3_5761_5784_AX_FIXES flag instead.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Matt.
