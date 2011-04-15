From: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
Subject: RE: SMSC 8720a/MDIO/PHY help.
Date: Fri, 15 Apr 2011 16:17:26 -0500
Message-ID: <9AC3F0E75060224C8BBC5BA2DDC8853A1FB1117D@EXV1.corp.adtran.com>
References: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com><1302729564.2742.28.camel@malcolm><9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8D4@EXV1.corp.adtran.com><BANLkTik7xeMnx0S2m0easY0hVT_UmomjzA@mail.gmail.com><9AC3F0E75060224C8BBC5BA2DDC8853A1FB11170@EXV1.corp.adtran.com> <BANLkTi=rzTCTackMiKRW=vciN=+ThiCGJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <michael@riesch.at>, <netdev@vger.kernel.org>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c12o148.mxlogic.net ([208.65.145.81]:42304 "EHLO
	p02c12o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757162Ab1DOVSp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 17:18:45 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <BANLkTi=rzTCTackMiKRW=vciN=+ThiCGJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andy Fleming [mailto:afleming@gmail.com]
> Sent: Friday, April 15, 2011 4:02 PM
> To: ANDY KENNEDY
> Cc: michael@riesch.at; netdev@vger.kernel.org
> Subject: Re: SMSC 8720a/MDIO/PHY help.
> > Now, where is the document that explains all this. =A0The PHY
> document is very informative, however, if you don't know that a PHY
> is NOT a network device, you're kinda outta luck. =A0Even Wiki
> reports a PHY as the Physical Link layer of the OSI model. =A0Which,
> again, doesn't tell the ignorant much.
>=20
>=20
> Take a look at Documentation/networking/netdevices.txt
>=20
> Also grep around in drivers/net to see networking drivers that have
> been ported to use phylib (look for phy_connect or phy_attach).

That's pretty much what I did.  After that, I was able (using my functi=
on stubs) to do an ifconfig eth0 and see that at least the kernel assig=
ned my IP address to the device (though nothing else worked, but that w=
as further than I was getting).

Like I said, I'm not completely ignorant anymore.  I look forward to th=
e day (perhaps Monday) when I'm only half ignorant ;).

Thanks for your help!

Andy
