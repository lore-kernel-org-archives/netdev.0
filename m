From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Check for POST state in suspend-resume
 sequence
Date: Tue, 27 Aug 2013 13:54:41 -0400 (EDT)
Message-ID: <20130827.135441.1119917926573500376.davem@davemloft.net>
References: <771abba1-2664-4807-9a45-56ca9ede3c74@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3H0Ryy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 13:54:54 -0400
In-Reply-To: <771abba1-2664-4807-9a45-56ca9ede3c74@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sarveshwar.bandi@emulex.com>
Date: Fri, 23 Aug 2013 14:59:33 +0530

> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> In suspend-resume sequence, the OS could attempt to initialize the controller
> before it is ready, check for POST state before going ahead.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Applied, thanks.
