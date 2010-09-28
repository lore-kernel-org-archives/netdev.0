From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 04/17] bnx2x: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Tue, 28 Sep 2010 10:39:16 -0700 (PDT)
Message-ID: <20100928.103916.226757256.davem@davemloft.net>
References: <1285611927.2263.296.camel@achroite.uk.solarflarecom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEDAE6E96@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEDAE6ECA@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750738Ab0I1Ri4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 13:38:56 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEDAE6ECA@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Tue, 28 Sep 2010 05:59:15 -0700

> Ben, I'm going to fix the bnx2x the way your patch would apply. I
> suspect this would probably require u to respin the bnx2x patch.
> Sorry for the inconvenience.

Ben's patch is already in the tree, so you need to send me patches
relative to his.
