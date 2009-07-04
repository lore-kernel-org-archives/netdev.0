From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: preferred lifetime of address not getting updated
Date: Fri, 03 Jul 2009 19:11:43 -0700 (PDT)
Message-ID: <20090703.191143.05168156.davem@davemloft.net>
References: <4A4CEA1C.3070606@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jens.rosenboom@freenet.ag
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756584AbZGDCLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 22:11:36 -0400
In-Reply-To: <4A4CEA1C.3070606@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Thu, 02 Jul 2009 13:10:52 -0400

> Update the preferred lifetime of IPv6 addresses derived from a prefix
> info option in a router advertisement even if the valid lifetime in
> the option is invalid, as specified in RFC 4862 Section 5.5.3e.  Fixes
> an issue where an address will not immediately become deprecated.
> Reported by Jens Rosenboom.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied.
