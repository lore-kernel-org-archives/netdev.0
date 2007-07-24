From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm state selection update to use inner
 addresses
Date: Tue, 24 Jul 2007 16:31:44 +0200
Message-ID: <46A60D50.804@trash.net>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707192054.38945.joakim.koskela@hiit.fi> <469FBECB.6080204@trash.net> <200707231119.25457.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: joakim.koskela@hiit.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58995 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbXGXOcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 10:32:14 -0400
In-Reply-To: <200707231119.25457.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
> This patch modifies the xfrm state selection logic to use the inner
> addresses where the outer have been (incorrectly) used. This is
> required for beet mode in general and interfamily setups in both
> tunnel and beet mode.


Looks good.

Acked-by: Patrick McHardy <kaber@trash.net>
