From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8169: remove the obsolete and incorrect AMD
 workaround
Date: Tue, 22 Jan 2013 19:42:29 -0500 (EST)
Message-ID: <20130122.194229.506495498894632095.davem@davemloft.net>
References: <20130121234205.GA12449@electric-eye.fr.zoreil.com>
	<1358843435-24719-1-git-send-email-timo.teras@iki.fi>
	<20130123000541.GA9515@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab3AWAma convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 19:42:30 -0500
In-Reply-To: <20130123000541.GA9515@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 23 Jan 2013 01:05:41 +0100

> Timo Ter=E4s <timo.teras@iki.fi> :
> [...]
>=20
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
>=20
> desc->opts2 is now a bit different in the RxRes path - the only path
> where the patch can be noticed. I hope it won't uncloak something els=
e.

=46rancois, do you want me to apply this directly or do you want
to submit this yourself along with any other r8169 changes you
might have queued up?

Thanks.
