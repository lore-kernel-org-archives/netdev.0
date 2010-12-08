From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] via-velocity: fix the WOL bug on 1000M full duplex
 forced mode
Date: Wed, 08 Dec 2010 12:56:19 -0800 (PST)
Message-ID: <20101208.125619.200379037.davem@davemloft.net>
References: <AANLkTi=+r4cjE-3RJgrsrVaPBz0Ok_7XqZ+dxZgFCCUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	DavidLv@viatech.com.cn, ShirleyHu@viatech.com.cn,
	AndersMa@viatech.com.cn
To: davidlv.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41307
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751773Ab0LHUzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:55:53 -0500
In-Reply-To: <AANLkTi=+r4cjE-3RJgrsrVaPBz0Ok_7XqZ+dxZgFCCUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lv <davidlv.linux@gmail.com>
Date: Wed, 8 Dec 2010 13:47:19 +0800

> The VIA velocity card can't be waken up by WOL tool on 1000M full
> duplex forced mode.
> This patch fixes the bug.
> Thanks!
> 
> Signed-off-by: David Lv <DavidLv@viatech.com.cn>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
 ...
> 
> -			MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF,
> MII_CTRL1000, vptr->mac_regs);

Your email client has corrupted the patch by chopping up long lines
etc., please correct this and resubmit your patch.
