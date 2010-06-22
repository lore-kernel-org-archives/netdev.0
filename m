From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] net: Introduce u64_stats_sync
 infrastructure
Date: Tue, 22 Jun 2010 19:31:06 +0200
Message-ID: <1277227866.3057.709.camel@edumazet-laptop>
References: <1276598605.2541.96.camel@edumazet-laptop>
	 <20100615110413.GJ6138@laptop> <1276608594.2541.119.camel@edumazet-laptop>
	 <20100622.102455.232729115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: npiggin@suse.de, netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42209 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759068Ab0FVRbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 13:31:12 -0400
Received: by wyi11 with SMTP id 11so59018wyi.19
        for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 10:31:11 -0700 (PDT)
In-Reply-To: <20100622.102455.232729115.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 juin 2010 =C3=A0 10:24 -0700, David Miller a =C3=A9crit :

> That's a really weird patch hunk for a newly added file.
>=20
> The hunk header is saying that the new file start 1 line
> in.  Which doesn't make any sense, and GIT reject this
> saying that you're trying to make a modification to a
> file which doesn't exist.
>=20
> I applied this by hand, but I really wonder how you managed
> to create such a patch :-)

Now you mention it, I remember I had problems about this newly added
file, and had to use several git commands to stabilize my tree.

I really dont know what happened exactly, sorry :!)

Thanks !


