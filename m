From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] bc47xx : fix ssb irq setup
Date: Thu, 11 Jun 2009 09:59:36 +0200
Message-ID: <200906110959.38132.florian@openwrt.org>
References: <4A11DBD4.7070706@free.fr> <200905191519.59193.mb@bu3sch.de> <4A1ADBAE.6070101@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Buesch <mb@bu3sch.de>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, Daniel Mueller <daniel@danm.de>
To: matthieu castet <castet.matthieu@free.fr>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:51015 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbZFKH7l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 03:59:41 -0400
Received: by ewy6 with SMTP id 6so1759811ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 00:59:42 -0700 (PDT)
In-Reply-To: <4A1ADBAE.6070101@free.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matthieu, Michael,

Le Monday 25 May 2009 19:55:58 matthieu castet, vous avez =C3=A9crit=C2=
=A0:
> Michael Buesch wrote:
> > On Tuesday 19 May 2009 00:06:12 matthieu castet wrote:
> >> Hi,
> >>
> >>
> >> [1] http://www.danm.de/files/src/bcm5365p/REPORTED_DEVICES
> >>
> >> Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>
> >
> > If this works on all devices, I'm OK with this. Please submit to
> > linville@tuxdriver.com You can add my ack.
>
> Well I have only a wl500gd.
> I have submit it on openwrt project in order to test in more devices.

It makes the IPsec core work on my Netgear WGT634U and I did not see an=
y=20
regression on a Linksys WRT54GS.

Tested-by: Florian Fainelli <florian@openwrt.org>
--=20
