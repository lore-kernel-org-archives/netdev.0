From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [NET] Exporting of some IPv6 symbols for HIP and SHIM6
 experimentation
Date: Mon, 05 May 2008 15:00:45 +0900 (JST)
Message-ID: <20080505.150045.29715304.yoshfuji@linux-ipv6.org>
References: <Pine.SOL.4.64.0804292344490.29274@kekkonen.cs.hut.fi>
	<20080429.152014.00555445.davem@davemloft.net>
	<Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: miika@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38625 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbYEEGAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 02:00:39 -0400
In-Reply-To: <Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi> (at Mon, 5 May 2008 08:55:49 +0300 (EEST)), Miika Komu <miika@iki.fi> says:

> On Tue, 29 Apr 2008, David Miller wrote:
:
> > This is not how we do things.
> >
> > When the HIP implementation is submitted for inclusion, the module
> > exports can be added, not before.
> 
> I am sorry but this somewhat conflicts with your earlier statement:
> 
> http://www.linux.sgi.com/archives/netdev/2005-03/msg01214.html
> 
> We took an huge effort in our project to move the HIP implementation to 
> the userland. I feel puzzled on how to continue. Please give some advice?

Miika, where are your other patches on top of this?
This kind of change might be okay, but it must be along with
its users, at least.

--yoshfuji
