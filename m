From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/33] sfc: Clean up board identification
Date: Fri, 12 Dec 2008 21:48:20 -0800 (PST)
Message-ID: <20081212.214820.202813003.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125418.GQ10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36441
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751363AbYLMFsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:48:19 -0500
In-Reply-To: <20081212125418.GQ10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:54:19 +0000

> Remove kluge for development boards with unspecified board type.
> 
> Remove assumption of contiguous board type code assignments.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
