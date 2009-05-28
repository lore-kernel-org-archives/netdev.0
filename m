From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] net: correct a comment for the final #endif
Date: Thu, 28 May 2009 09:05:36 +0200
Message-ID: <20090528070535.GA21538@psychotron.englab.brq.redhat.com>
References: <20090527140153.GE1652@psychotron.englab.brq.redhat.com> <20090527.154911.39711918.davem@davemloft.net> <20090528054712.GA20533@psychotron.englab.brq.redhat.com> <20090527.233344.74118227.davem@davemloft.net> <4A1E31A7.6090905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42297 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907AbZE1HFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2009 03:05:46 -0400
Content-Disposition: inline
In-Reply-To: <4A1E31A7.6090905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 28, 2009 at 08:39:35AM CEST, eric.dumazet@gmail.com wrote:
>David Miller a =E9crit :
>> From: Jiri Pirko <jpirko@redhat.com>
>> Date: Thu, 28 May 2009 07:47:13 +0200
>>=20
>>> Btw how do you choose what patch to apply to what tree?
>>=20
>> It depends upon where we are in the development cycle and the
>> nature of your patch.
>>=20
>> Right now we're only applying the most critical bug fixes
>> to net-2.6, anything else goes to net-next-2.6
>>=20
>
>I append here some extra stuff
>
>net-2.6 is the tree for pending patches for Linus, for the about to be
>released version (2.6.30 as today)
>
>As the merge window (for 2.6.30) is now closed, only bug fixes are all=
owed.
>
>For cleanups, and new network stuff (possibly introducing new bugs),
>net-next-2.6 is the right tree. This gives time for various testers
>to discover bugs so we can fix them before hitting public release.
>
>When Linus releases 2.6.30, opening merge window of one week, then all=
 patches
>pending in net-next-2.6 will take their way to Linus tree for 2.6.31
>
>Some exceptions are allowed, but this is the general idea.
>
>Hope this helps

=46ine, thanks you both guys.
>
