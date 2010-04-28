From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bnx2x: Remove two prefetch()
Date: Wed, 28 Apr 2010 14:33:21 +0200
Message-ID: <1272458001.2267.0.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36958 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab0D1Mdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 08:33:37 -0400
Received: by bwz19 with SMTP id 19so18347bwz.21
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 05:33:36 -0700 (PDT)
In-Reply-To: <1272454432.14068.4.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 avril 2010 =C3=A0 07:33 -0400, jamal a =C3=A9crit :
> On Wed, 2010-04-28 at 00:18 +0200, Eric Dumazet wrote:
>=20
> > Thanks David, I was about to resubmit the cumulative patch ;)
>=20
> Hrm, i never got the email with your patch on top of Changlis
> (the fscking ISP has creative ways of reordering, delaying and also
> occassionaly loosing my emails). So all my tests from last
> week did not include the extra patch. I will try to make time today
> to test with latest net-next which seems to have some extra goodies.
> If there is any other patch you want me to try let me know...
>=20
> cheers,
> jamal

If you wait a bit, I have another patch to speedup udp receive path ;)


