From: Arkadiusz Miskiewicz <arekm@maven.pl>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Thu, 19 Jul 2007 08:19:53 +0200
Message-ID: <200707190819.53364.arekm@maven.pl>
References: <200707182218.13548.arekm@maven.pl> <469E9CF7.1040403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.carme.maven.pl ([193.239.45.138]:14807 "EHLO
	main.carme.maven.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363AbXGSGT7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 02:19:59 -0400
In-Reply-To: <469E9CF7.1040403@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 of July 2007, Patrick McHardy wrote:
> Arkadiusz Miskiewicz wrote:
> > I'm having problems with networking on recent git kernel.
> >
> > kernel logs tons of "Virtual device lo asks to queue packet!"
> > and networking stops working correctly:
> >
> > CONFIG_NETDEVICES_MULTIQUEUE=3Dy
>
> Does it go away if you disable this option?

Yes, it goes away after disabling this.

--=20
Arkadiusz Mi=B6kiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
