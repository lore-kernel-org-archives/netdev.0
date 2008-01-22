From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 1/4][BNX2]: Disable jumbo rx paging on 5709 Ax.
Date: Mon, 21 Jan 2008 17:06:19 -0800 (PST)
Message-ID: <20080121.170619.61666158.davem@davemloft.net>
References: <1200964052.10010.46.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752203AbYAVBGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 20:06:13 -0500
In-Reply-To: <1200964052.10010.46.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 21 Jan 2008 17:07:32 -0800

> [BNX2]: Disable jumbo rx paging on 5709 Ax.
> 
> The chip has problem running in this mode and needs to be disabled.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
