From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: oops with ipcomp
Date: Thu, 7 Feb 2008 19:01:32 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F20CE@exch.facton.local>
References: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local> <20080206170717.GA20308@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20C0@exch.facton.local> <20080207154437.GA7237@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:52256 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932550AbYBGSBl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 13:01:41 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080207154437.GA7237@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> OK, so are you now able to reproduce this crash without waiting
> for hours? That would be really helpful in tracking it down.

Yes, I can reproduce it in minutes now.

> Could you show me the exact policies/SAs of the tunnel involved
> in the crash?

esp/cbc(aes128)/hmac(sha1)
--------------------------------------------------------

Mit freundlichen Gr=FC=DFen
i.A. Daniel Beschorner
Entwicklung
  =20
=46ACTON GmbH
Prager Str. 2
01069 Dresden

Tel.: +49-351-40223-0
Mobil: +49-151-54446012
=46ax: +49-351-40223-15
Mail: Daniel.Beschorner@facton.com
Web: www.facton.com


--------------------------------------------------------
Neuer FACTON-Unternehmensauftritt im Internet: www.facton.com=20
Alle Schulungstermine 2008 in der =DCbersicht: www.facton.com/akademie2=
008 --------------------------------------------------------


Vertretungsberechtigte Gesch=E4ftsf=FChrer: Thoralf Nehls, Martin Nehls=
=20
Sitz der Gesellschaft: Prager Stra=DFe 2, 01069 Dresden=20
Handelsregister: Amtsgericht Dresden HRB 17304


--------------------------------------------------------

"This email message is intended only for the person(s) to whom it is ad=
dressed
and as such is confidential. If you have received this communication in=
 error,
please notify us immediately and delete the original message.
Thank you for your cooperation."
