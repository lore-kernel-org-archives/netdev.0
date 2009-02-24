From: David Miller <davem@davemloft.net>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 23 Feb 2009 22:46:52 -0800 (PST)
Message-ID: <20090223.224652.121864647.davem@davemloft.net>
References: <Pine.LNX.4.64.0902212042420.20526@wrl-59.cs.helsinki.fi>
	<20090221.235308.172360407.davem@davemloft.net>
	<b6a2187b0902232240m6f2347efs84639bb59a19269e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, herbert@gondor.apana.org.au,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jeff.chua.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38774
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751476AbZBXGrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 01:47:12 -0500
In-Reply-To: <b6a2187b0902232240m6f2347efs84639bb59a19269e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Chua <jeff.chua.linux@gmail.com>
Date: Tue, 24 Feb 2009 14:40:30 +0800

> On Sun, Feb 22, 2009 at 3:53 PM, David Miller <davem@davemloft.net> wrote:
> 
> > Sure, but I'll give Herbert one more chance :-)
> >
> > Applied to net-next-2.6
> 
> I see that this is already in linux-2.6.29-rc6. Tested and working fine.

Actually, it isn't.

Herbert's change is in net-next-2.6 which will show up in linux-next
rather than Linus's 2.6.29-rcX tree.
