From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: can: mscan: fix build breakage in mpc5xxx_can
Date: Wed, 13 Apr 2011 11:33:49 -0700 (PDT)
Message-ID: <20110413.113349.115927274.davem@davemloft.net>
References: <1302688168-26862-1-git-send-email-agust@denx.de>
	<4DA57F55.7080304@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agust@denx.de, netdev@vger.kernel.org, grant.likely@secretlab.ca
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55141
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756638Ab1DMSeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 14:34:25 -0400
In-Reply-To: <4DA57F55.7080304@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 13 Apr 2011 12:47:49 +0200

> On 04/13/2011 11:49 AM, Anatolij Gustschin wrote:
>> Commit 74888760d40b3ac9054f9c5fa07b566c0676ba2d
>> "dt/net: Eliminate users of of_platform_{,un}register_driver"
>> broke building mscan driver. Fix it.
>> 
>> Signed-off-by: Anatolij Gustschin <agust@denx.de>
>> Cc: Grant Likely <grant.likely@secretlab.ca>
> 
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

I'll apply this to net-2.6, thanks everyone.
