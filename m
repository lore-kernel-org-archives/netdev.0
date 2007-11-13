From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/13] tg3: CPMU adjustments for loopback tests
Date: Mon, 12 Nov 2007 21:12:04 -0800 (PST)
Message-ID: <20071112.211204.15796544.davem@davemloft.net>
References: <1194655132.5745.268.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44158
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760643AbXKMFMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:12:05 -0500
In-Reply-To: <1194655132.5745.268.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:52 -0800

> This patch adds the LINK_SPEED mode to the list of CPMU modes that can
> cause the loopback tests to fail.  These bugs are planned to be fixed in
> future revisions of the chip, so the patch qualifies the fixes as such.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks!
