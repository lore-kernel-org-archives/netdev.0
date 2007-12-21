From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] tg3: Correct 5704S flowctrl advertisements
Date: Thu, 20 Dec 2007 20:09:07 -0800 (PST)
Message-ID: <20071220.200907.134016331.davem@davemloft.net>
References: <1198191602.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754909AbXLUEJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:09:08 -0500
In-Reply-To: <1198191602.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 20 Dec 2007 15:00:02 -0800

> This patch modifies the 5704S hardware autoneg code to use the
> administrator specified flow control parameters.  Since the 5704S uses
> device specific flow control enumerations, the 1000-BaseX utility
> functions are used and code was added to convert the definitions to and
> from the proprietary enumerations.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
