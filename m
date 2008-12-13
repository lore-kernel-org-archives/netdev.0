From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/33] sfc: Rework MAC, PHY and board event handling
Date: Fri, 12 Dec 2008 21:59:33 -0800 (PST)
Message-ID: <20081212.215933.14483251.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125545.GU10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYLMF7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:59:32 -0500
In-Reply-To: <20081212125545.GU10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:55:47 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> MAC, PHY and board events may be separately enabled and signalled.
> Our current arrangement of chaining the polling functions can result
> in events being missed.  Change them to be more independent.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
