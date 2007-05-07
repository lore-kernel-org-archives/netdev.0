From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH revised 9/11][TG3]: Add ASPM workaround.
Date: Mon, 07 May 2007 00:26:46 -0700 (PDT)
Message-ID: <20070507.002646.108741305.davem@davemloft.net>
References: <463BD269.7010501@garzik.org>
	<20070505.131005.85669827.davem@davemloft.net>
	<1178410709.4859.49.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58122
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754052AbXEGH0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 03:26:48 -0400
In-Reply-To: <1178410709.4859.49.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 05 May 2007 17:18:29 -0700

> [TG3]: Add ASPM workaround.
> 
> This patch adds workaround to fix performance problems caused by slow
> PCIE L1->L0 transitions on ICH8 platforms.
> 
> Changed all magic numbers to constants as suggested by Jeff Garzik.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
