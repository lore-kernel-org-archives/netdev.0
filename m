From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [stable] [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when
 vid not used
Date: Thu, 09 Dec 2010 02:25:33 +0100
Message-ID: <1291857933.2795.7.camel@edumazet-laptop>
References: <1291108809.2904.3.camel@edumazet-laptop>
	 <20101201111716.424fb771@xenia.leun.net>
	 <1291200914.2856.546.camel@edumazet-laptop>
	 <20101208.084731.189716071.davem@davemloft.net>
	 <20101208231624.GA8992@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, lkml20101129@newton.leun.net,
	netdev@vger.kernel.org, jesse@nicira.com,
	linux-kernel@vger.kernel.org, greearb@candelatech.com,
	stable@kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101208231624.GA8992@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 15:16 -0800, Greg KH a =C3=A9c=
rit :
> On Wed, Dec 08, 2010 at 08:47:31AM -0800, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 01 Dec 2010 11:55:14 +0100
> >=20
> >=20
> > Greg/-stable, please integrate this patch from Eric into 2.6.36 if =
you
> > haven't already done so.
>=20
> I've updated the version in the .36-stable queue with this one, thank=
s.
>=20

Thanks.

By the way, all credits given to Jesse, I only made a change to his
patch, so I left him as the author.

Ah I see I forgot the "From: Jesse Gross <jesse@nicira.com>" header whe=
n
I sent it, my bad, sorry !
