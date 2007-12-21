From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] tg3: Correct sw autoneg flow control advertisements
Date: Thu, 20 Dec 2007 20:09:37 -0800 (PST)
Message-ID: <20071220.200937.170435809.davem@davemloft.net>
References: <1198191605.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755443AbXLUEJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:09:37 -0500
In-Reply-To: <1198191605.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 20 Dec 2007 15:00:05 -0800

> This patch modifies the software autoneg code to use the administrator
> specified flow control parameters.  Since the autonegotiation code uses
> alternative flow control enumerations, the 1000-BaseX utility functions
> are used and code was added to convert the definitions to and from the
> alternate enumerations.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
