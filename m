From: Andrew Watts <akwatts@ymail.com>
Subject: Re: kernel panic with time-stamping in phy devices (monitor mode)
Date: Sat, 4 Dec 2010 12:46:46 -0800 (PST)
Message-ID: <906429.41845.qm@web111015.mail.gq1.yahoo.com>
References: <1291450622.2806.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm14.bullet.mail.ne1.yahoo.com ([98.138.90.77]:30373 "HELO
	nm14.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755831Ab0LDUqs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Dec 2010 15:46:48 -0500
In-Reply-To: <1291450622.2806.59.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Sat, 12/4/10, Eric Dumazet wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Subject: Re: kernel panic with time-stamping in phy devices (monitor =
mode)
> To: "Richard Cochran" <richardcochran@gmail.com>
> Cc: "Andrew Watts" <akwatts@ymail.com>, netdev@vger.kernel.org, "Davi=
d Miller" <davem@davemloft.net>
> Date: Saturday, December 4, 2010, 8:17 AM
> Le samedi 04 d=E9cembre 2010 =E0 08:57
> +0100, Richard Cochran a =E9crit :
> > Date: Sat, 4 Dec 2010 08:55:04 +0100
> > From: Richard Cochran <richardcochran@gmail.com>
> > To: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Andrew Watts <akwatts@ymail.com>,
> netdev@vger.kernel.org,
> > =A0=A0=A0 David Miller <davem@davemloft.net>
> > Subject: Re: kernel panic with time-stamping in phy
> devices (monitor mode)
> > Message-ID: <20101204075503.GA3490@riccoc20.at.omicron.at>
> > References: <252997.92320.qm@web111013.mail.gq1.yahoo.com>
> >=A0
> <1291307884.2871.69.camel@edumazet-laptop>
> > MIME-Version: 1.0
> > Content-Type: text/plain; charset=3Dus-ascii
> > Content-Disposition: inline
> > In-Reply-To:
> <1291307884.2871.69.camel@edumazet-laptop>
> > User-Agent: Mutt/1.5.20 (2009-06-14)
> >=20
> > Ugh, new kernel code with no users is already causing
> trouble!
> >=20
> > On Thu, Dec 02, 2010 at 05:38:04PM +0100, Eric Dumazet
> wrote:
> > > Thanks for the report
> > >=20
> > > Please try following patch.
> >=20
> > And thank you, Eric, for the quick patch.
> >=20
> > Can this fix go into 2.6.37, please?
>=20
> Sure, I'll submit to David today, thanks !
>=20

Eric, I echo the thanks on the lightning patch.
Impressive turnaround!

There's an open bug report on the kernel's bugzilla
for 2.6.36 (#24102). What is the best way to tie these
together?

~ Andy



     =20
