From: Brian Haley <brian.haley@hp.com>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying to
 ifenslave a second interface to my bond
Date: Tue, 14 Apr 2009 17:29:14 -0400
Message-ID: <49E5002A.2030204@hp.com>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com> <1239724882.8944.553.camel@psmith-ubeta.netezza.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul@mad-scientist.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:34471 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbZDNV3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 17:29:16 -0400
In-Reply-To: <1239724882.8944.553.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Smith wrote:
> Is anyone else able to use mode=6 with the bonding driver, or is that
> mode just non-functional?  Is it something particular to these Broadcom
> drivers?

The only help I can give you right now is that on my test system it doesn't crash.

	Bonding Driver: v3.5.0 (November 4, 2008)
	2x Broadcom NetXtreme II BCM5708

The kernel itself is stock 2.6.29 and I'm running on an x86_64 box, not exactly
embedded :)

-Brian
