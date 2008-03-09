From: "Jann Traschewski" <jann@gmx.de>
Subject: Re: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
Date: Sun, 9 Mar 2008 18:34:47 +0100
Message-ID: <001101c8820b$e0409880$453c822c@dg8ngn>
References: <20080206074529.GC4496@ff.dom.local> <20080213115607.GB2867@ff.dom.local> <025801c86ea3$75add3f0$453c822c@dg8ngn> <47D3A7AF.1030607@free.fr> <20080309143052.GA2749@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'David Miller'" <davem@davemloft.net>,
	"'Ralf Baechle'" <ralf@linux-mips.org>, <netdev@vger.kernel.org>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>, "'Pidoux'" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:43204 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751845AbYCIRew convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 13:34:52 -0400
In-Reply-To: <20080309143052.GA2749@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Indeed. I'd like to see it in 2.6.24. My heavy used machine has no prob=
lems
with this patch since 13 days now.
Thank you,
Jann

> -----Urspr=FCngliche Nachricht-----
> Von: Jarek Poplawski [mailto:jarkao2@gmail.com]=20
> Gesendet: Sonntag, 9. M=E4rz 2008 15:31
> An: Pidoux
> Cc: Jann Traschewski; 'David Miller'; 'Ralf Baechle';=20
> netdev@vger.kernel.org
> Betreff: Re: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick(=
)
>=20
> On Sun, Mar 09, 2008 at 10:02:39AM +0100, Pidoux wrote:
> ...
> >>> Subject: [AX25] ax25_out: check skb for NULL in ax25_kick()
> ...
> > Applied too and stable with kernel 2.6.24.3 since a week.
>=20
> Good to know! It's merged to 2.6.25-rc3, but maybe recommending it fo=
r
> 2.6.24 wouldn't be a bad idea...
>=20
> Thanks Bernard,
> Jarek P.

