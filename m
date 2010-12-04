From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic with time-stamping in phy devices (monitor mode)
Date: Sat, 04 Dec 2010 09:17:02 +0100
Message-ID: <1291450622.2806.59.camel@edumazet-laptop>
References: <252997.92320.qm@web111013.mail.gq1.yahoo.com>
	 <1291307884.2871.69.camel@edumazet-laptop>
	 <20101204075750.GA3949@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Watts <akwatts@ymail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58177 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658Ab0LDIRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 03:17:08 -0500
Received: by wyb28 with SMTP id 28so10283285wyb.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 00:17:06 -0800 (PST)
In-Reply-To: <20101204075750.GA3949@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 d=C3=A9cembre 2010 =C3=A0 08:57 +0100, Richard Cochran a =C3=
=A9crit :
> Date: Sat, 4 Dec 2010 08:55:04 +0100
> From: Richard Cochran <richardcochran@gmail.com>
> To: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Andrew Watts <akwatts@ymail.com>, netdev@vger.kernel.org,
> 	David Miller <davem@davemloft.net>
> Subject: Re: kernel panic with time-stamping in phy devices (monitor =
mode)
> Message-ID: <20101204075503.GA3490@riccoc20.at.omicron.at>
> References: <252997.92320.qm@web111013.mail.gq1.yahoo.com>
>  <1291307884.2871.69.camel@edumazet-laptop>
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3Dus-ascii
> Content-Disposition: inline
> In-Reply-To: <1291307884.2871.69.camel@edumazet-laptop>
> User-Agent: Mutt/1.5.20 (2009-06-14)
>=20
> Ugh, new kernel code with no users is already causing trouble!
>=20
> On Thu, Dec 02, 2010 at 05:38:04PM +0100, Eric Dumazet wrote:
> > Thanks for the report
> >=20
> > Please try following patch.
>=20
> And thank you, Eric, for the quick patch.
>=20
> Can this fix go into 2.6.37, please?

Sure, I'll submit to David today, thanks !


