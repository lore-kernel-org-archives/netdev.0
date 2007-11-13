From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/13] tg3: Limit 5784 / 5764 to MAC LED mode
Date: Mon, 12 Nov 2007 21:17:23 -0800 (PST)
Message-ID: <20071112.211723.87306644.davem@davemloft.net>
References: <1194655137.5745.270.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750747AbXKMFRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:17:24 -0500
In-Reply-To: <1194655137.5745.270.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:56 -0800

> Most 5784 / 5764 LED modes do not work as expected because of a hardware
> bug.  This patch forces the LED mode to be in MAC LED mode.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Patch applied, thanks Matt.
