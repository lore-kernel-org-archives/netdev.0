From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by
 ISDN
Date: Mon, 15 Oct 2007 02:12:03 -0700 (PDT)
Message-ID: <20071015.021203.28411623.davem@davemloft.net>
References: <20071008155836.GA19932@pingi.kke.suse.de>
	<20071008.203733.132907566.davem@davemloft.net>
	<20071012140521.GA28413@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@lisas.de, jeff@garzik.org, isdn4linux@listserv.isdn4linux.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	shemminger@linux-foundation.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754113AbXJOJL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:11:59 -0400
In-Reply-To: <20071012140521.GA28413@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karsten Keil <kkeil@suse.de>
Date: Fri, 12 Oct 2007 16:05:22 +0200

> This is a followup to the previous ISDN alloc_netdev() patch.
> It removes the local copy of the device name to make sure
> that device renames work.
> 
> Signed-off-by: Karsten Keil <kkeil@suse.de>

Applied, thanks!
