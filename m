From: Kirill Kapranov <kapranoff@inbox.ru>
Subject: Re: [PATCH] phy: Elimination the forced speed reduction algorithm.
Date: Mon, 01 Apr 2013 17:51:44 +0400
Message-ID: <1364824304.6276.28.camel@kkk.nita.ru>
References: <1364304872-6408-1-git-send-email-kapranoff@inbox.ru>
	 <20130329.143808.647821389772332250.davem@davemloft.net>
Reply-To: kapranoff@inbox.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	peppe.cavallaro@st.com, joe@perches.com, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130329.143808.647821389772332250.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


=46ri, 29/03/2013 14:38 -0400, David Miller =D0=C9=DB=C5=D4:
> Why are you posting this again?  I've applied your patch 3 days
> ago.

oops...
The last letter I sent was a coding style correction -- removing
trailing whitespace in response to remark of Tue, 26 Mar 2013 12:59:13
-0400 (EDT)  by David Miller:
>=20
>=20
> > -                                     phy_force_reduction(phydev);
> > +                             if (0 =3D=3D phydev->link_timeout--)=20
>                                                                 ^^^^
> Trailing whitespace, please remove.

I sent it  Wed, 27 Mar 2013 15:16:13 +0400

After receiving confirmation (Wed, 27 Mar 2013 13:11:02 -0400 (EDT))

> Applied.

from David Miller, I haven't sent any post.
