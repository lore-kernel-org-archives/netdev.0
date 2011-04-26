From: Bandan Das <bandan.das@stratus.com>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in
 ip_fragment
Date: Tue, 26 Apr 2011 16:59:01 -0400
Message-ID: <20110426205901.GN15903@stratus.com>
References: <20110426203154.GM15903@stratus.com>
 <20110426.134637.48491363.davem@davemloft.net>
 <1303851185.2699.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bandan.das@stratus.com,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	tom@dbservice.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.stratus.com ([134.111.1.17]:35117 "EHLO
	mailhub4.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756548Ab1DZU7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 16:59:36 -0400
Content-Disposition: inline
In-Reply-To: <1303851185.2699.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  0, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le mardi 26 avril 2011 =C3=A0 13:46 -0700, David Miller a =C3=A9crit =
:
>=20
> > This patch is mangled by your email client, tab characters
> > have been turned into spaces, so it won't be usable by anyone.
>=20
> Thats strange, I thought it was already in linux-2.6 anyway ?
>=20
Umm.. I could be wrong! I just did a quick grep for your name in the=20
2.6.39-rc4 changelog :=20
http://www.kernel.org/pub/linux/kernel/v2.6/testing/ChangeLog-2.6.39-rc=
4

and didn't find it there.

--
Bandan
