From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Sat, 5 Apr 2008 12:06:37 +1100
Message-ID: <200804051206.37394.nickpiggin@yahoo.com.au>
References: <adYyJ-20N-11@gated-at.bofh.it> <200804042159.54220.nickpiggin@yahoo.com.au> <Pine.LNX.4.58.0804041307500.9036@be10.lrz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Bodo Eggert <7eggert@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp112.mail.mud.yahoo.com ([209.191.84.65]:32723 "HELO
	smtp112.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751378AbYDEBGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 21:06:45 -0400
In-Reply-To: <Pine.LNX.4.58.0804041307500.9036@be10.lrz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 April 2008 22:35, Bodo Eggert wrote:
> On Fri, 4 Apr 2008, Nick Piggin wrote:

> > But actually developers do sometimes want see the event even if it is
> > relatively infrequent...
>
> You shouldn't frighten the users either. /proc/sys/vm/debug?

Hence changing the message a to make it clear that it is not a
problem if it is infrequent.
