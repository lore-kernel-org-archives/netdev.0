From: Florian Fainelli <florian@openwrt.org>
Subject: Re: 802.1Q support?
Date: Tue, 13 Jan 2009 14:29:39 +0100
Message-ID: <200901131429.41178.florian@openwrt.org>
References: <200901121148.26905.rgetz@blackfin.uclinux.org> <200901122143.51004.florian@openwrt.org> <200901130731.20538.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>,
	Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:57647 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbZAMN36 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 08:29:58 -0500
Received: by bwz14 with SMTP id 14so3857bwz.13
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 05:29:56 -0800 (PST)
In-Reply-To: <200901130731.20538.rgetz@blackfin.uclinux.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tuesday 13 January 2009 13:31:20 Robin Getz, vous avez =C3=A9crit=C2=
=A0:
> Great - That looks like the way to go -- is there any plan in sending=
 this
> to mainline?

Yes we will definitively submit it for mainline inclusion, Felix, who w=
rote=20
the swconfig stuff will probably want to clean it up a bit and/or add=20
features.

Lennert Buytenhek also proposed a Distributed Switch Architecture which=
 is=20
worth looking at, though it does not cover more "classical" switches=20
connection over GPIO, SPI or special PHY address.

>
> It looks like it has been in your tree for ~9 months - so I imagine i=
t
> is working pretty well for you?

Yes, we are shipping this in the Kamikaz 8.09rc1 release, no bug report=
=20
related to swconfig have been filed so far ;)
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
