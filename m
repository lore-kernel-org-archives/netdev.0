From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 19:19:10 +0200
Message-ID: <1275499150.2519.0.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1006021126500.30182@router.home>
	 <1275496439.2725.203.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021140320.30182@router.home>
	 <20100602.101258.134121018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:34537 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756370Ab0FBRTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:19:15 -0400
Received: by wwb28 with SMTP id 28so3079380wwb.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 10:19:13 -0700 (PDT)
In-Reply-To: <20100602.101258.134121018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 10:12 -0700, David Miller a =C3=A9crit =
:
> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Wed, 2 Jun 2010 11:49:18 -0500 (CDT)
>=20
> > On Wed, 2 Jun 2010, Eric Dumazet wrote:
> >=20
> >> take a look at
> >>
> >> http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/html/Sys=
temTap_Beginners_Guide/useful-systemtap-scripts.html#dropwatch
> >=20
> > System tap?
>=20
> You don't need to use system tap, just the normal tracing stuff using
> sysfs files suffices.
>=20

It would be good if Neil could gave us a man page or something ;)



