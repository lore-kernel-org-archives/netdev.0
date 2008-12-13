From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/33] sfc: Add support for MMDs numbered >15
Date: Fri, 12 Dec 2008 21:44:25 -0800 (PST)
Message-ID: <20081212.214425.168521724.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125339.GO10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751992AbYLMFoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:44:24 -0500
In-Reply-To: <20081212125339.GO10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:53:40 +0000

> Combine DEVS0 and DEVS1 registers into a 32-bit mask instead of
> reading just DEVS0.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
