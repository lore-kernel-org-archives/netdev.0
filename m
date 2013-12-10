From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [patch net-next] ipv6 addrconf: revert /proc/net/if_inet6 ifa_flag
 format
Date: Tue, 10 Dec 2013 14:51:52 +0100
Message-ID: <52A71C78.8090902@enst-bretagne.fr>
References: <1386680189-7852-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:48857 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631Ab3LJNvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 08:51:55 -0500
In-Reply-To: <1386680189-7852-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/12/2013 13:56, Jiri Pirko a =E9crit :
> Turned out that applications like ifconfig do not handle the change.
> So revert ifa_flag format back to 2-letter hex value.
>=20

Tested-by: FLorent Fourcot <florent.fourcot@enst-bretagne.fr>

It solves the problem, thank you.
