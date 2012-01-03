From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] igb: Add support for byte queue limits.
Date: Tue, 03 Jan 2012 07:07:46 +0100
Message-ID: <1325570866.2874.10.camel@edumazet-laptop>
References: <1324480695.2301.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111221.144207.1402252938319338463.davem@davemloft.net>
	 <9BBC4E0CF881AA4299206E2E1412B626011AB6@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:65261 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab2ACGHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 01:07:51 -0500
Received: by werm1 with SMTP id m1so7683903wer.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 22:07:50 -0800 (PST)
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B626011AB6@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 21:17 +0000, Wyborny, Carolyn =
a =C3=A9crit :
>=20
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org]
> >On Behalf Of David Miller
> >Sent: Wednesday, December 21, 2011 11:42 AM
> >To: eric.dumazet@gmail.com
> >Cc: netdev@vger.kernel.org; Kirsher, Jeffrey T; Duyck, Alexander H
> >Subject: Re: [PATCH net-next] igb: Add support for byte queue limits=
=2E
> >
> >From: Eric Dumazet <eric.dumazet@gmail.com>
> >Date: Wed, 21 Dec 2011 16:18:15 +0100
> >
> >> This adds support for byte queue limits (BQL)
> >>
> >> Since this driver collects bytes count in 'bytecount' field, use i=
t
> >also
> >> in igb_tx_map()
> >>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> CC: Alexander Duyck <alexander.h.duyck@intel.com>
> >
> >Intel folks, you got this?
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> Yes, although many are out for the holidays.=20
>=20
> ACK.  We'll get it into our queue for testing.

Any news on this patch ?

I would like it being added for next merge window.

By the way I did test it on my machine.

Thanks
