From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/33] sfc: Correct interpretation of second param to
 ethtool phys_id()
Date: Fri, 12 Dec 2008 21:32:20 -0800 (PST)
Message-ID: <20081212.213220.149700848.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212124950.GE10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752427AbYLMFcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:32:18 -0500
In-Reply-To: <20081212124950.GE10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:49:50 +0000

> A value of 0 means indefinite repetition (until interrupted).
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
