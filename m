From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] ISDN patches for 2.6.32 (v2)
Date: Sat, 26 Sep 2009 20:24:32 -0700 (PDT)
Message-ID: <20090926.202432.51893536.davem@davemloft.net>
References: <20090919-patch-capi-0.tilman@imap.cc>
	<4ABDFE9F.2030404@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, keil@b1-systems.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60911
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753251AbZI0DYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 23:24:13 -0400
In-Reply-To: <4ABDFE9F.2030404@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sat, 26 Sep 2009 13:44:31 +0200

> Hello Karsten,
> 
> is there any chance of getting these and the Gigaset patches forwarded
> for inclusion in 2.6.32 before the merge window closes?
> If not all of them, perhaps at least those which you had already acked
> before David Miller asked that they should formally go through you
> (#2-4 of the ISDN series), and those which are just fixes to the
> existing i4l version of the driver (#1-10 of the Gigaset series)?
> I would really appreciate not having to maintain all of them out of
> tree for another release cycle.

I am extremely disappointed in the lack of respinsiveness of Karsten
to ISDN patches.  He wants to handle them, but he has effectively
disappeared during the most critical time for patch integration, which
is during the merge window.

If he's busy in life or whatever, that's fine, but in such a case he
should appoint someone to handle ISDN patches until he does have time.

And if no ISDN expert is available, Tilman's suggestion of letting
me integrate the patches should be taken.
