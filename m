From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] MACsec IEEE 802.1AE implementation
Date: Sun, 13 Mar 2016 22:41:25 -0400 (EDT)
Message-ID: <20160313.224125.1212706098465112754.davem@davemloft.net>
References: <cover.1457714618.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	stephen@networkplumber.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254AbcCNCl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:41:28 -0400
In-Reply-To: <cover.1457714618.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 11 Mar 2016 18:07:30 +0100

> MACsec (IEEE 802.1AE [0]) is a protocol that provides security for
> wired ethernet LANs.  MACsec offers two protection modes:
> authentication only, or authenticated encryption.
 ...
> Implementation
 ...
> Netlink API
 ...
> Use cases
 ...

Probably one of the best cover letters for a new feature written in
quite a while, nice work.

Series applied, thanks!
