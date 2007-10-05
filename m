From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 5 Oct 2007 08:39:24 -0700
Message-ID: <20071005083924.4e7f5d59@freepuppy.rosehill>
References: <20071005.031209.57156822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56058 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751915AbXJEPj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 11:39:57 -0400
In-Reply-To: <20071005.031209.57156822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I just checked the following into net-2.6.24, besides minor
> tweaks and bug fixes, this is probably what is going to Linus.
> 
> I verified it builds no just on sparc64 but also even on 32-bit
> platforms such as x86. :-)
> 
> Thanks!

Build failed on x86_64

ERROR: "__bad_udelay" [drivers/net/niu.ko] undefined!
