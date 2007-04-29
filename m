From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] Rename get_property to of_get_property: drivers/net
Date: Sun, 29 Apr 2007 00:43:48 -0700
Message-ID: <20070429004348.ea30f3fc.akpm@linux-foundation.org>
References: <20070427145508.9c5641a2.sfr@canb.auug.org.au>
	<4633689E.50900@garzik.org>
	<20070429114446.31f40a30.sfr@canb.auug.org.au>
	<20070428.204754.62343452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, jeff@garzik.org, paulus@samba.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:55597 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755031AbXD2Hod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 03:44:33 -0400
In-Reply-To: <20070428.204754.62343452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 28 Apr 2007 20:47:54 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Sun, 29 Apr 2007 11:44:46 +1000
> 
> > So can I take this as a future OK for architecture specific network
> > drivers changes to go through the architecture trees (cc'd to you)?
> 
> It's been my experience that if I'm just working through some
> platform or bus specific API changes, people like Jeff tend to
> not mind if it goes via ARCH trees and the like.

This all started with me having a dummyspit over yet another huge reject
because of intersections between subsystem trees.

Normally we get away with it but when there's so much material pending,
things deteriorate.

