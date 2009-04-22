From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net, 83xx] ucc_geth.c: Fix upsmr setting in RMII mode
Date: Wed, 22 Apr 2009 00:46:53 -0700 (PDT)
Message-ID: <20090422.004653.250792561.davem@davemloft.net>
References: <49ED859B.30904@denx.de>
	<2a27d3730904210351s870f015gb896a4b874b3024b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hs@denx.de, gridish@freescale.com, galak@kernel.crashing.org,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752173AbZDVHrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 03:47:01 -0400
In-Reply-To: <2a27d3730904210351s870f015gb896a4b874b3024b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>
Date: Tue, 21 Apr 2009 18:51:11 +0800

> On Tue, Apr 21, 2009 at 4:36 PM, Heiko Schocher <hs@denx.de> wrote:
>> If using the UCC on a MPC8360 in RMII mode, don;t set
>> UCC_GETH_UPSMR_RPM bit in the upsmr register.
>>
>> Signed-off-by: Heiko Schocher <hs@denx.de>
> 
> Acked-by: Li Yang <leoli@freescale.com>

Applied, thanks.
