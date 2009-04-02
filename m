From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc35815: Fix build error if NAPI enabled
Date: Thu, 02 Apr 2009 01:17:46 -0700 (PDT)
Message-ID: <20090402.011746.188752053.davem@davemloft.net>
References: <1238511902-6853-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754658AbZDBIR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:17:58 -0400
In-Reply-To: <1238511902-6853-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Wed,  1 Apr 2009 00:05:02 +0900

> This driver contains experimental NAPI code disabled by default.
> The commit bea3348ee ("[NET]: Make NAPI polling independent of struct
> net_device objects.") converted the NAPI path of this driver but that
> conversion was not complete.  This patch fixes a build error
> introduced by the commit.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied, thank you.
