From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Refine VPD logic.
Date: Thu, 03 Dec 2009 15:58:11 -0800 (PST)
Message-ID: <20091203.155811.239397300.davem@davemloft.net>
References: <1259881656-6693-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44988
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753570AbZLCX6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:58:05 -0500
In-Reply-To: <1259881656-6693-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 3 Dec 2009 15:07:36 -0800

> - Replace magic values with constants
> - Simplify length calculation and fix a bug
> 
> Based on valuable feedback from Ben Hutchings <bhutchings@solarflare.com>
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks for following up on this Michael.
