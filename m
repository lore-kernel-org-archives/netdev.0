From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Sun, 12 Nov 2006 22:47:54 +0100
Message-ID: <200611122247.54388.mb@bu3sch.de>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de> <200611122243.14287.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:9440
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1753255AbWKLVtc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 16:49:32 -0500
To: Ismail Donmez <ismail@pardus.org.tr>
In-Reply-To: <200611122243.14287.ismail@pardus.org.tr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 12 November 2006 21:43, Ismail Donmez wrote:
> Hi,
> 12 Kas 2006 Paz 10:34 tarihinde =C5=9Funlar=C4=B1 yazm=C4=B1=C5=9Ft=C4=
=B1n=C4=B1z:
> > Ah, and also note that you _need_ firmware from a v4 binary driver
> > to have hardware encryption with bcm43xx.
>=20
> Last time I heard only v3 firmware was supported. Is that changed?

Yes, wireless-dev supports v4 firmware (and even requires it for
advanced features like hw encryption)

--=20
Greetings Michael.
