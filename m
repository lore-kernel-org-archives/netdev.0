From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] tg3: Enable GPHY APD on select devices
Date: Fri, 21 Nov 2008 17:19:10 -0800 (PST)
Message-ID: <20081121.171910.08047442.davem@davemloft.net>
References: <1227295575.5618@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57965
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755330AbYKVBTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:19:10 -0500
In-Reply-To: <1227295575.5618@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 21 Nov 2008 11:01:12 -0800

> GPHY Autopowerdown (APD) is a way to save power when energy is not
> detected on the wire.  At the moment, only the 5784 and 5761 are
> apable of enabling this mode.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
