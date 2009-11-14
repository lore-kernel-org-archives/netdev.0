From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] can: Fix driver Kconfig structure
Date: Fri, 13 Nov 2009 19:58:14 -0800 (PST)
Message-ID: <20091113.195814.209044836.davem@davemloft.net>
References: <4AFBF2E5.1090909@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757595AbZKND56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:57:58 -0500
In-Reply-To: <4AFBF2E5.1090909@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Thu, 12 Nov 2009 12:35:01 +0100

> In 2.6.32-rc the new EMS USB CAN driver was contributed and added the Kconfig
> entry right behind an entry of the same *vendor*. This teared the SJA1000
> based driver selection into pieces.
> 
> This fix cleans up the 2.6.32-rc Kconfig files for the CAN drivers and moves
> the SJA1000 and USB Kconfig portions into the belonging directories.
> 
> As there are many new CAN drivers in the queue getting this cleanup into
> 2.6.32-rc would massively reduce the problems for the upcoming drivers.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied.
