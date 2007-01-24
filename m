From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] process include/linux/if_{addr,link}.h with unifdef
Date: Tue, 23 Jan 2007 22:05:17 -0800 (PST)
Message-ID: <20070123.220517.115910657.davem@davemloft.net>
References: <20070121191319.GO9093@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030227AbXAXGFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:05:18 -0500
In-Reply-To: <20070121191319.GO9093@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 21 Jan 2007 20:13:19 +0100

> After commit d3dcc077bf88806201093f86325ec656e4dbfbce, 
> include/linux/if_{addr,link}.h should be processed with unifdef.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.

I believe at least the 2.6.19 -stable branch will need
this too, right?  Please submit to -stable as needed,
and feel free to add my sign-off:

Signed-off-by: David S. Miller <davem@davemloft.net>
