From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre: optimize hash lookup
Date: Mon, 26 Jan 2009 20:56:18 -0800 (PST)
Message-ID: <20090126.205618.109565383.davem@davemloft.net>
References: <1232690553-31865-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40325
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbZA0E4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 23:56:21 -0500
In-Reply-To: <1232690553-31865-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Fri, 23 Jan 2009 08:02:33 +0200

> Instead of keeping candidate tunnel device from all categories,
> keep only one candidate with best score. This optimizes stack
> usage and speeds up exit code.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Applied, thanks a lot.
