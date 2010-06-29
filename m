From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6.35-rc3] micrel phy driver - updated(1)
Date: Tue, 29 Jun 2010 00:58:50 -0700 (PDT)
Message-ID: <20100629.005850.108788514.davem@davemloft.net>
References: <C43529A246480145B0A6D0234BDB0F0D0212A3@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754118Ab0F2H6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 03:58:36 -0400
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0D0212A3@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Mon, 28 Jun 2010 18:23:41 -0700

> 
> Hello all:
> 
> This patch fixes what Ben mentioned, namely duplicated ids.
> 
> From: David J. Choi <david.choi@micrel.com>
> 
> Body of the explanation: This patch has changes as followings;
>  -support the interrupt from phy devices from Micrel Inc.
>  -support more phy devices, ks8737, ks8721, ks8041, ks8051 from Micrel.
>  -remove vsc8201 because this device was used only internal test at Micrel.
> 
> Signed-off-by: David J. Choi <david.choi@micrel.com>

Applied to net-next-2.6
