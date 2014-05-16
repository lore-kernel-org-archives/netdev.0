From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pch_gbe depends on x86_32
Date: Fri, 16 May 2014 17:01:22 -0400 (EDT)
Message-ID: <20140516.170122.2194249516724862833.davem@davemloft.net>
References: <20140516112904.7072da0f@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jslaby@suse.cz
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467AbaEPVBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 17:01:24 -0400
In-Reply-To: <20140516112904.7072da0f@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Fri, 16 May 2014 11:29:04 +0200

> The pch_gbe driver is for a companion chip to the Intel Atom E600
> series processors. These are 32-bit x86 processors so the driver is
> only needed on X86_32.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied to net-next, thanks.
