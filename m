From: David Miller <davem@davemloft.net>
Subject: Re: [patch 02/11] net/irda/: proper prototypes
Date: Mon, 05 Feb 2007 18:01:42 -0800 (PST)
Message-ID: <20070205.180142.35665788.davem@davemloft.net>
References: <200702060031.l160VuqL004621@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de, samuel@sortiz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33251
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965393AbXBFCBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:01:42 -0500
In-Reply-To: <200702060031.l160VuqL004621@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:30:53 -0800

> From: Adrian Bunk <bunk@stusta.de>
> 
> Add proper prototypes for some functions in include/net/irda/irda.h
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Acked-by: Samuel Ortiz <samuel@sortiz.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I NAK'd this so that Adrian would go add "extern" to the
function declarations in the header file.

Please drop this, Adrian will resend once he fixes it up.
