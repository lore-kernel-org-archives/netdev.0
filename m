From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: [PATCH 2/5] [SCTP]: "list_for_each()" -> "list_for_each_entry()"
 where appropriate.
Date: Thu, 10 Apr 2008 19:07:16 -0400 (EDT)
Message-ID: <alpine.LFD.1.00.0804101906560.25839@localhost.localdomain>
References: <1207856394-19321-3-git-send-email-vladislav.yasevich@hp.com> <alpine.LFD.1.00.0804101545570.24254@localhost.localdomain> <47FE70C9.3070009@hp.com> <20080410.153618.40472986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:37385 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbYDJXHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 19:07:25 -0400
In-Reply-To: <20080410.153618.40472986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Apr 2008, David Miller wrote:

> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Thu, 10 Apr 2008 15:55:53 -0400
>
> > Robert P. J. Day wrote:
> > >   actually, if i remember correctly, davem rejected that change as
> > > being too disruptive at the moment, no?
> >
> > this is for 2.6.26, which should be fine.  it was too disruptive for net.26.
>
> Right.

ok, i stand corrected.  carry on.

rday
--

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
