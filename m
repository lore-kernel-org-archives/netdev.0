From: David Miller <davem@davemloft.net>
Subject: Re: net/dccp: expansion of error code size
Date: Mon, 24 May 2010 18:37:26 -0700 (PDT)
Message-ID: <20100524.183726.264769230.davem@davemloft.net>
References: <20100524154508.10a40589.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: yuasa@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47375
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758185Ab0EYBhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 21:37:16 -0400
In-Reply-To: <20100524154508.10a40589.yuasa@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoichi Yuasa <yuasa@linux-mips.org>
Date: Mon, 24 May 2010 15:45:08 +0900

> Because MIPS's EDQUOT value is 1133(0x46d).
> It's larger than u8.
> 
> Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>

Applied, thank you.
