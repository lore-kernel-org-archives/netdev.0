From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sis190: Rx filter init is needed for MAC address
 change.
Date: Thu, 28 Jul 2011 00:39:06 -0700 (PDT)
Message-ID: <20110728.003906.2105088753594027041.davem@davemloft.net>
References: <20110728071123.GA11286@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klement2@azet.sk
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab1G1HjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 03:39:16 -0400
In-Reply-To: <20110728071123.GA11286@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 28 Jul 2011 09:11:23 +0200

> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=34552
> 
> Signed-off-by: Klement Fish <klement2@azet.sk>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

So who wrote this patch?

If it's Klement, you need to add a "From: Klement Fish <klement2@azet.sk>"
to the body of your email so that GIT sets the authorship correctly.

If it's you, why are you only ACK'ing and not signing off on the change?

Either way you need to resubmit this :-)
