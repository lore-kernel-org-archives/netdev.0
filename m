From: "Kumar Gopalpet-B05799" <Sandeep.Kumar@freescale.com>
Subject: RE: [PATCH v0 1/7] gianfar: Add per queue structure support
Date: Tue, 20 Oct 2009 12:15:14 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B8940DB@zin33exm22.fsl.freescale.net>
References: <12556242491498-git-send-email-sandeep.kumar@freescale.com> <20091019.231633.25328647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:60736 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbZJTGpQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 02:45:16 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n9K6jJRb008395
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 23:45:20 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n9K6mLWn003237
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 01:48:22 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20091019.231633.25328647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI David,

I am assuming all the 7 patches are applied.

-Thanks
Sandeep

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Tuesday, October 20, 2009 11:47 AM
>To: Kumar Gopalpet-B05799
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH v0 1/7] gianfar: Add per queue structure support
>
>
>These changes look pretty good and I've let them sit on the 
>list for several days so I'm applying them to net-next-2.6, thanks!
>
>
