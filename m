From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] IPv6: Generic TTL Security Mechanism (original
 version)
Date: Thu, 22 Apr 2010 14:38:05 -0700 (PDT)
Message-ID: <20100422.143805.95887767.davem@davemloft.net>
References: <20100403232103.923025940@vyatta.com>
	<20100403232922.489187907@vyatta.com>
	<20100422092305.0e45f547@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org, nick@inex.ie,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40012
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751096Ab0DVViA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 17:38:00 -0400
In-Reply-To: <20100422092305.0e45f547@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 Apr 2010 09:23:05 -0700

> Dave: Yoshifuji and I agree this is the best solution, how come the patch
> hasn't been applied?

You supplied 3 different implementations, that puts all of them
into "RFC" state in patchwork.

When you figure out which one is best you make a new explicit
submission of the implementation you think should actually
go into the tree.
