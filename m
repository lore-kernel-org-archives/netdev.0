From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] stuff from tcp-2.6 partially merged to upcoming
 net-2.6.24?
Date: Wed, 08 Aug 2007 03:55:05 -0700 (PDT)
Message-ID: <20070808.035505.110907605.davem@davemloft.net>
References: <Pine.LNX.4.64.0708071356060.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751246AbXHHKzF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 06:55:05 -0400
In-Reply-To: <Pine.LNX.4.64.0708071356060.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 7 Aug 2007 16:19:58 +0300 (EEST)

> Do you have any suggestion how I should proceed? Or do you perhaps ob=
ject=20
> such partial merge completely? ...I could try to come up with a clean=
ed up=20
> patch series which has original and their bug fix parts combined to a=
=20
> single patch per change (would provide cleaner history and shouldn't =
be=20
> very hard to do either)...

Thank you for doing the rebase.  I agree with you that we should
seperate out as much of the non-rb-tree stuff as possible and put it
into net-2.6.24

I'll will try hard to make time to look at your rebase and try to move
things forward.  I've been all-consumed by the NAPI work and a driver
I've been writing in the background for the past few weeks.

