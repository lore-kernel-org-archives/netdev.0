From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] isdn/capi: move capi_info2str to capidrv.c
Date: Fri, 23 May 2014 15:03:03 -0400 (EDT)
Message-ID: <20140523.150303.460858514446894387.davem@davemloft.net>
References: <365e4f40e1aace19c3233305085ed929b30387b8.1400449370.git.tilman@imap.cc>
	<537D99F6.4040500@linux-pingi.de>
	<1400794689.16407.57.camel@x220>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kkeil@linux-pingi.de, tilman@imap.cc, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, isdn@linux-pingi.de
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbaEWTDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 15:03:05 -0400
In-Reply-To: <1400794689.16407.57.camel@x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 22 May 2014 23:38:09 +0200

> Anyhow, this patch might complicate your local debugging practices. That
> might be inconvenient for you. But in mainline we see a function that's
> used in one place only. And I think cleaning up mainline code is what
> counts.

+1
