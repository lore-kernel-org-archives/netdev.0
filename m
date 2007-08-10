From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 03/18] drivers/net/ns83820.c: add paramter to disable
 autonegotiation
Date: Fri, 10 Aug 2007 16:45:13 -0700
Message-ID: <20070810164513.3d0b4e24.akpm@linux-foundation.org>
References: <200708102105.l7AL5ERH008951@imap1.linux-foundation.org>
	<20070810211349.GD978@kvack.org>
	<20070810151818.df28b709.akpm@linux-foundation.org>
	<506359130708101552n5023c81dvdb314bec26e70925@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Benjamin LaHaise" <bcrl@kvack.org>, jeff@garzik.org,
	netdev@vger.kernel.org, dan@scannet.dk, jgarzik@pobox.com
To: "Logix -" <thelogix@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33427 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754165AbXHJXpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 19:45:47 -0400
In-Reply-To: <506359130708101552n5023c81dvdb314bec26e70925@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 11 Aug 2007 00:52:38 +0200
"Logix -" <thelogix@gmail.com> wrote:

> On 8/11/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > > > [akpm: this is a previously-nacked patch, but the problem is real]
> >
> > I think I'll drop the whole patch.  I've been nursing the thing along for
> > 1.5 years and I don't recall seeing any reports of any bugs which it would
> > have fixed anyway.
> >
> 
> Except, using this card for sniffing using a passive fiber-tap cant be done,
> since with autoneg enabled, the card is set on half-duplex. Might not be a
> bug, but definitely a problem for me. But if im the only one in the world
> who needs this, so be it.
> 

Feel free to send a new patch.  It could be based on this one, but please
review the comments which people have had when this patch was sent on
earlier occasions.

http://marc.info/?l=linux-netdev&w=2&r=1&s=add+paramter+to+disable+autonegotiation&q=b is a decent start.

Thanks.
