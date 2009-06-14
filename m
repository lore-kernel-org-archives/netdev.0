From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: update ARPD help text
Date: Sat, 13 Jun 2009 23:38:44 -0700 (PDT)
Message-ID: <20090613.233844.69081494.davem@davemloft.net>
References: <20090611.205906.215886308.davem@davemloft.net>
	<1244785082-7883-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46408
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751740AbZFNGil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 02:38:41 -0400
In-Reply-To: <1244785082-7883-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Fri, 12 Jun 2009 08:38:02 +0300

> Removed the statements about ARP cache size as this config option does
> not affect it. The cache size is controlled by neigh_table gc thresholds.
> 
> Remove also expiremental and obsolete markings as the API originally
> intended for arp caching is useful for implementing ARP-like protocols
> (e.g. NHRP) in user space and has been there for a long enough time.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Applied.
