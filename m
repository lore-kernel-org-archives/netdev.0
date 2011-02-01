From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bnx2x: multicasts in NPAR mode
Date: Tue, 01 Feb 2011 14:05:44 -0800 (PST)
Message-ID: <20110201.140544.183041487.davem@davemloft.net>
References: <201102011257.11610.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753227Ab1BAWFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 17:05:09 -0500
In-Reply-To: <201102011257.11610.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vlad Zolotarov" <vladz@broadcom.com>
Date: Tue, 1 Feb 2011 12:57:10 +0200

> The chip was erroneously configured to accept all multicast frames
> in a normal (none-promisc) rx mode both on the RSS and on the FCoE L2 rings
> when in an NPAR mode. This caused packet duplication for every received multicast
> frame in this mode.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks Vlad.
