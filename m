From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Tue, 06 Dec 2011 13:13:19 -0500 (EST)
Message-ID: <20111206.131319.2237133596554595319.davem@davemloft.net>
References: <igorm@etf.rs>
	<1323162824-3196-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com, romieu@fr.zoreil.com
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118Ab1LFSOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:14:31 -0500
In-Reply-To: <1323162824-3196-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: igorm@etf.rs
Date: Tue,  6 Dec 2011 10:13:44 +0100

> From: Igor Maravic <igorm@etf.rs>
> 
> Changes to r8169 to use byte queue limits.
> 
> Signed-off-by: Igor Maravic <igorm@etf.rs>

Your change is only valid after Francois's fixes right?  That's what you
say in another email.

Well, you're targetting this change to the net-next tree, are Francois's
fixes there?

They aren't, so you need to be patient and not be so eager like a rabbit
to keep mindlessly pumping this patch to the list.
