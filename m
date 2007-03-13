From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Mon, 12 Mar 2007 17:02:53 -0700 (PDT)
Message-ID: <20070312.170253.122618823.davem@davemloft.net>
References: <20070306114808.GA22724@havoc.gtf.org>
	<Pine.LNX.4.62.0703121100260.16343@pademelon.sonytel.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, fubar@us.ibm.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert.Uytterhoeven@sonycom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbXCMACy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 20:02:54 -0400
In-Reply-To: <Pine.LNX.4.62.0703121100260.16343@pademelon.sonytel.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Date: Mon, 12 Mar 2007 11:02:43 +0100 (CET)

> On Tue, 6 Mar 2007, Jeff Garzik wrote:
> > Jay Vosburgh (3):
> >       bonding: Improve IGMP join processing
> 
> ip_mc_rejoin_group: Kill warning about unused variable `in_dev' when
> CONFIG_IP_MULTICAST is not set.
> 
> Signed-off-by: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

Applied, thanks Geert.
