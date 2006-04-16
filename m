From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] sungem: Marvell PHY suspend
Date: Sun, 16 Apr 2006 14:35:04 +1000
Message-ID: <1145162105.9833.2.camel@localhost.localdomain>
References: <1145148738.6560.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:29625 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1751104AbWDPEfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2006 00:35:17 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145148738.6560.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-04-16 at 02:52 +0200, Johannes Berg wrote:
> In a short discussion with Benjamin Herrenschmidt he mentioned
> that Marvell PHYs are powered down the same way as the other
> ones we currently handle. Thus actually do that, hopefully
> saving some power during suspend.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>


