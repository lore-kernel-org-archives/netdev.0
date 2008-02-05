From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 16:14:53 +0000
Message-ID: <20080205161453.151e23e0@core>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
	<20080205155558.GA23145@one.firstfloor.org>
	<20080205154213.059ac6e8@core>
	<20080205163912.GB23145@one.firstfloor.org>
	<20080205160301.7b2369ee@core>
	<20080205164837.GC23145@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:39086 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751154AbYBEQUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 11:20:36 -0500
In-Reply-To: <20080205164837.GC23145@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What kind of LISTEN ports? And does it matter if they're DoS'ed?

I guess that depends on the opinion of the owner

- Push based mobile services
- Email delivery
- VoIP
- Management ports
- Peer to peer data transfer
- Instant messaging direct user/user connections

Some of that can also be hardened using IP filter rules

> > Is the other stuff enough - good question, and can be measured easily
> > enough on a little dlink router or similar.
> 
> My guess would be that it is.

Alan
