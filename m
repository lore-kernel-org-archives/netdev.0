From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: net_assign_generic() fix
Date: Sun, 02 Aug 2009 12:27:11 -0700 (PDT)
Message-ID: <20090802.122711.237194942.davem@davemloft.net>
References: <4A6EF0BF.2050801@gmail.com>
	<4A6EF705.6070403@openvz.org>
	<4A6EFA35.3060309@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@openvz.org, for.poige+bugzilla.kernel.org@gmail.com,
	akpm@linux-foundation.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751908AbZHBT1E convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Aug 2009 15:27:04 -0400
In-Reply-To: <4A6EFA35.3060309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Jul 2009 15:16:37 +0200

> Pavel Emelyanov a =E9crit :
>>> Hmm...
>>>
>>> Real bug may be fixed by followed patch ? (yet untested, sorry...)
>>>
>>> [PATCH] net: net_assign_generic() fix=20
>>>
>>> memcpy() should take into account size of pointers,
>>> not only number of pointers to copy.
>>>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>=20
>> Acked-by: Pavel Emelyanov <xemul@openvz.org>
>=20
> Thanks.

Applied, thanks!
