From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge extensions to iproute2
Date: Tue, 10 Jul 2012 15:06:44 -0700
Message-ID: <20120710150644.0a68d05a@nehalam.linuxnetplumber.net>
References: <CAHo-Ooyk_=UYsEtz-y6hupCtMOgKz2DF+j1BOnSsmAfm-5Bkqg@mail.gmail.com>
	<20120710145821.748c00be@nehalam.linuxnetplumber.net>
	<CAHo-OozFCrcx4FpsuNzEV4Cp_4hbVw896utpstYL2qcD1EwCyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54052 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133Ab2GJWG7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 18:06:59 -0400
In-Reply-To: <CAHo-OozFCrcx4FpsuNzEV4Cp_4hbVw896utpstYL2qcD1EwCyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jul 2012 15:01:26 -0700
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> > I will get back to these. There wasn't a motivation to go fast beca=
use
> > there wasn't a user of these. Now with fdb offload support they are=
 needed.
>=20
> Do you have some semi-ready patches that could be used for test purpo=
ses?
>=20
> While it looks like the forwarding database capability is there in th=
e kernel,
> I can't currently find an interface to turn learning off.

I'll put something in today.
