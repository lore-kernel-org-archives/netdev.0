From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cassini: init before use in cas_interruptN.
Date: Fri, 26 Aug 2011 12:52:42 -0400 (EDT)
Message-ID: <20110826.125242.1773171670646830462.davem@davemloft.net>
References: <201108251558.45290.thomas.jarosch@intra2net.com>
	<20110825150249.GA21897@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.jarosch@intra2net.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab1HZQww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:52:52 -0400
In-Reply-To: <20110825150249.GA21897@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 25 Aug 2011 17:02:49 +0200

> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Spotted-by: Thomas Jarosch <thomas.jarosch@intra2net.com>

Applied, thanks!

>  David, any opinion regarding the removal of the USE_NAPI #ifdef
>  in this driver ?

No objections to removing it.
