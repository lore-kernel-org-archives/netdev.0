From: Ming-Ching Tiew <mctiew@yahoo.com>
Subject: Re: Linux arp flux problem
Date: Mon, 12 Apr 2010 19:18:06 -0700 (PDT)
Message-ID: <382005.89009.qm@web31503.mail.mud.yahoo.com>
References: <908408.23515.qm@web31502.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web31503.mail.mud.yahoo.com ([68.142.198.132]:27479 "HELO
	web31503.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754543Ab0DMCSI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 22:18:08 -0400
In-Reply-To: <908408.23515.qm@web31502.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Mon, 4/12/10, Ming-Ching Tiew <mctiew@yahoo.com> wrote:

> From: Ming-Ching Tiew <mctiew@yahoo.com>
> Subject: Linux arp flux problem
> To: "Net Dev" <netdev@vger.kernel.org>
> Date: Monday, April 12, 2010, 3:16 AM
>=20
> The following link explains the Linux arp flux problem
> pretty well, and I myself have been burnt badly by a life
> site where the "arp_filter" does not help at all.
>=20
> =A0 =A0 =A0 =A0=A0=A0http://linux-ip.net/html/ether-arp.html
>=20
> And I tested the kernel patch by Julian Anastasov, and it
> works 100% reliably :-
>=20
> =A0 =A0 =A0 =A0=A0=A0http://www.ssi.bg/~ja/#hidden
>=20
> My question is the patches has been around for many years,
> why has it not been included into the kernel ? Is it that
> Linux is supposed to have this "side effects" of arp linux
> on purpose ?
>=20

May I propose that the said patch ( http://www.ssi.bg/~ja/#hidden )
be accepted into the kernel. And if it does not qualify, may I know why=
 ?

Thank you.


     =20
