From: David Miller <davem@davemloft.net>
Subject: Re: nonlocal_bind and IPv6
Date: Fri, 16 Dec 2011 02:06:00 -0500 (EST)
Message-ID: <20111216.020600.1695776769736304587.davem@davemloft.net>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx>
	<CAHo-OoxrYpFMBVfriB7HhL-BpMXJgCe1-mL4L8UpsDQJifMZvQ@mail.gmail.com>
	<m3zket9gqj.fsf@neo.luffy.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zenczykowski@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: bernat@luffy.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067Ab1LPHIN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 02:08:13 -0500
In-Reply-To: <m3zket9gqj.fsf@neo.luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Vincent Bernat <bernat@luffy.cx>
Date: Fri, 16 Dec 2011 07:24:04 +0100

> OoO En  ce milieu  de nuit  =E9toil=E9e du vendredi  16 d=E9cembre  2=
011, vers
> 04:58, Maciej =AFenczykowski <zenczykowski@gmail.com> disait=A0:
>=20
>> why not simply use the IP_TRANSPARENT or IP_FREEBIND socket options?
>=20
> Because  this requires  modifying each  affected software.  This  can=
 be
> difficult if you don't have the source code available.

But it means that it would work on every single kernel verion out
there.
