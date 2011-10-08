From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] igb : rtnl assert on resume
Date: Sat, 08 Oct 2011 22:16:40 +0200
Message-ID: <1318105000.5276.29.camel@edumazet-laptop>
References: <1318096284.5276.25.camel@edumazet-laptop>
	 <1318098396.23688.169.camel@jtkirshe-mobl>
	 <1318102192.5276.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51903 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878Ab1JHUQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 16:16:44 -0400
Received: by wyg34 with SMTP id 34so4841552wyg.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 13:16:43 -0700 (PDT)
In-Reply-To: <1318102192.5276.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 08 octobre 2011 =C3=A0 21:29 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le samedi 08 octobre 2011 =C3=A0 11:26 -0700, Jeff Kirsher a =C3=A9cr=
it :
>=20
> > Any chance you can pull my net-next tree Eric to verify if the issu=
e
> > still exists?
>=20
> Sure, I'll do that.
>=20

Same error with your changes as well.

No hurry, maybe the RTNL assert can be relaxed.
