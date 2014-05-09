From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: avm: potential signedness issue in loading
 firmware
Date: Fri, 09 May 2014 15:19:10 -0400 (EDT)
Message-ID: <20140509.151910.652580712245159131.davem@davemloft.net>
References: <20140509115437.GA31764@mwanda>
	<20140509.132403.531379541580867189.davem@davemloft.net>
	<20140509175244.GL4963@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, security@kernel.org,
	henry@henryhoggard.co.uk
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaEITTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 15:19:11 -0400
In-Reply-To: <20140509175244.GL4963@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 9 May 2014 20:52:44 +0300

> Let's just leave this as is.

Fair enough.
