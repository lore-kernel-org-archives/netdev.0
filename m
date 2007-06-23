From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 10:23:31 +0200
Message-ID: <20070623082331.GA23309@via.ecp.fr>
References: <450943.57686.qm@web25715.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, dlstevens@us.ibm.com,
	simon@fire.lp0.eu, cscott@laptop.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from durga.via.ecp.fr ([138.195.130.75]:60400 "EHLO durga.via.ecp.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585AbXFWIyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 04:54:12 -0400
Content-Disposition: inline
In-Reply-To: <20070622.221229.125566330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 23, 2007, David Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> >         Auto-configured addresses are used by the kernel. It has to
> > have those addresses. But the kernel doesn't do DNS look-ups, or
> > write resolv.conf; that's the difference, for me.
>=20
> I totally agree with David, this stuff definitely does not belong
> in the kernel.

It is my understanding that you think that IP stack configuration
belongs in the kernel whereas DNS does not, right?

Then I have a question: does RS-RA management belong in the kernel or
not?

--=20
Pierre Ynard
WTS #51 - No phone
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
