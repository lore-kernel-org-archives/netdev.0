From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipl2tp: allow setting session interface name
Date: Tue, 3 Apr 2012 11:39:31 -0700
Message-ID: <20120403113931.2dc759af@s6510.linuxnetplumber.net>
References: <4F70CAC8.10900@ist.utl.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "=?UTF-8?B?Sm/Do28=?= Valverde" <jpv950@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55836 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841Ab2DCSjj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 14:39:39 -0400
In-Reply-To: <4F70CAC8.10900@ist.utl.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Mar 2012 21:00:08 +0100
"Jo=C3=A3o Valverde" <jpv950@gmail.com> wrote:

> Hi,
>=20
> I've attached a trivial patch for iproute2 to allow naming interfaces=
=20
> created with "ip l2tp add session".
>=20
> I believe patches should go through the netdev mailing list but this=20
> patch is so small I figured that would just add noise. Hope that's OK=
=2E
>=20
> Originally I thought I would need a bigger patch and was going to tak=
e a=20
> stab at implementing something like
>=20
> ip l2tp add tunnel L2TP_TUNNEL_ARGS
> ip link add name NAME  [ LINK_OPTS ] type l2tp L2TP_SESSION_ARGS
>=20
> (a better interface IMHO) but all the code was there already, all tha=
t I=20
> needed to add was option parsing.
>=20
> Thanks,
>=20
> Jo=C3=A3o Valverde
>=20
>=20

Applied thanks.
