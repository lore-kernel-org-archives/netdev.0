From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bonding...
Date: Thu, 03 Mar 2011 17:52:37 +0100
Message-ID: <1299171157.2983.136.camel@edumazet-laptop>
References: <20110302.214910.112578818.davem@davemloft.net>
	 <1299159991.4277.45.camel@localhost>  <20110303083110.4e7f020c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33403 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758207Ab1CCQwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 11:52:42 -0500
Received: by bwz15 with SMTP id 15so1322138bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 08:52:41 -0800 (PST)
In-Reply-To: <20110303083110.4e7f020c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 08:31 -0800, Stephen Hemminger a =C3=A9cri=
t :
> On Thu, 03 Mar 2011 13:46:31 +0000
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>=20
> > On Wed, 2011-03-02 at 21:49 -0800, David Miller wrote:
> > [...]
> > > This is unacceptable, people are submitting multiple bonding patc=
hes
> > > every single day now.  It needs a clueful bonding person looking =
at
> > > these submissions on a constant basis.
> > [...]
> >=20
> > And preferably saying 'no' to most new features...
>=20
> Agreed. It seems bonding has diverged from the standards and wants
> to support every packet flow some user can think up.

A simple setup that was working in 2.6.35 doesnt work anymore here

vlan.103 - bond0 - eth3   (tg3 nic)

With a bnx2 nic, it works

Not sure its a bond problem, more probably a vlan one...



