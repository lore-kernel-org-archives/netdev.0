From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/13] tg3: MII => TP
Date: Mon, 12 Nov 2007 21:22:53 -0800 (PST)
Message-ID: <20071112.212253.157118732.davem@davemloft.net>
References: <1194655147.5745.274.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42506
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751786AbXKMFWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:22:54 -0500
In-Reply-To: <1194655147.5745.274.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:39:07 -0800

> This patch changes the PHY type reported through ethtool for copper
> devices from MII to TP.  The latter is more accurate.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Patch applied, thanks.
