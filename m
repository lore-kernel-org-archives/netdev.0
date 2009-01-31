From: David Miller <davem@davemloft.net>
Subject: Re: compile fix for ip6mr.c
Date: Sat, 31 Jan 2009 00:51:58 -0800 (PST)
Message-ID: <20090131.005158.138772609.davem@davemloft.net>
References: <20090131023357.GA16406@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml@gelk.kernelslacker.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751290AbZAaIwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 03:52:01 -0500
In-Reply-To: <20090131023357.GA16406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Fri, 30 Jan 2009 21:33:57 -0500

> net/ipv6/ip6mr.c: In function 'pim6_rcv':
> net/ipv6/ip6mr.c:368: error: implicit declaration of function 'csum_ipv6_magic'
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied, thanks a lot Dave.
