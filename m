From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] be2net fixes
Date: Thu, 05 Dec 2013 00:11:11 -0500 (EST)
Message-ID: <20131205.001111.273727362951023546.davem@davemloft.net>
References: <72e434bb-7c52-4dbe-a406-c6e0ad49e909@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3LEFLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 00:11:14 -0500
In-Reply-To: <72e434bb-7c52-4dbe-a406-c6e0ad49e909@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 5 Dec 2013 10:34:00 +0530

>   be2net: Log a kernel message when the user tries to configure more
>     Multicast addresses than supported

This is absolutely not appropriate.
