From: David Miller <davem@davemloft.net>
Subject: Re: [net 00/10] bnx2x: Link fixes
Date: Wed, 04 Apr 2012 18:25:17 -0400 (EDT)
Message-ID: <20120404.182517.2107875257385210734.davem@davemloft.net>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab2DDWZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:25:21 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Wed, 4 Apr 2012 14:28:53 +0300

> The following patch series describe some link fixes.
> These changes were held back a while until testing was completed to insure the
> issues are really fixed. And though they are minor issues, we still prefer to
> push those fixes to net and not just net-next as they improve the usability.
> Please consider applying it to net.

I understand how you might have held these back for internal testing,
but letting so many fixes queue up at one time creates a review burdon
for myself and other developers on this list.

Please try to submit smaller sets at a time in the future.

Anyways, all applied, thanks.
