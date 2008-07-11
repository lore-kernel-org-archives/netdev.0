From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bridge] bridging with gre tunnel
Date: Fri, 11 Jul 2008 12:07:17 -0700
Message-ID: <20080711120717.0c59e569@extreme>
References: <4876FDF0.1030807@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Timo =?UTF-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55312 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbYGKTHU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 15:07:20 -0400
In-Reply-To: <4876FDF0.1030807@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jul 2008 09:30:08 +0300
Timo Ter=C3=A4s <timo.teras@iki.fi> wrote:

> Hi all,
>=20
> It looks the current kernel still do not support bridging over gre
> tunnels.
>=20
> I did find an old patch for ip_gre that would enable this [1]. But
> it needs porting from 2.4 to 2.6 kernels and looks like it needs
> cleaning up too.
>=20
> Is there newer/better patches to achieve this? Any thoughts about
> doing bridging with gre tunnels?
>=20
> Cheers,
>   Timo
>=20
> [1] http://mailman.ds9a.nl/pipermail/lartc/2003q4/010327.html

The idea is fine, but that patch needs work (kind of a mess).
If you want it, then go through normal process of submitting to
netdev and take the comments and fix it up.
