From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when
 vid not used
Date: Thu, 9 Dec 2010 12:13:35 -0800
Message-ID: <20101209201335.GB28159@kroah.com>
References: <1291108809.2904.3.camel@edumazet-laptop>
 <20101201111716.424fb771@xenia.leun.net>
 <1291200914.2856.546.camel@edumazet-laptop>
 <20101208.084731.189716071.davem@davemloft.net>
 <20101208231624.GA8992@kroah.com>
 <1291857933.2795.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, lkml20101129@newton.leun.net,
	netdev@vger.kernel.org, jesse@nicira.com,
	linux-kernel@vger.kernel.org, greearb@candelatech.com,
	stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291857933.2795.7.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 09, 2010 at 02:25:33AM +0100, Eric Dumazet wrote:
> Le mercredi 08 d=E9cembre 2010 =E0 15:16 -0800, Greg KH a =E9crit :
> > On Wed, Dec 08, 2010 at 08:47:31AM -0800, David Miller wrote:
> > > From: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date: Wed, 01 Dec 2010 11:55:14 +0100
> > >=20
> > >=20
> > > Greg/-stable, please integrate this patch from Eric into 2.6.36 i=
f you
> > > haven't already done so.
> >=20
> > I've updated the version in the .36-stable queue with this one, tha=
nks.
> >=20
>=20
> Thanks.
>=20
> By the way, all credits given to Jesse, I only made a change to his
> patch, so I left him as the author.
>=20
> Ah I see I forgot the "From: Jesse Gross <jesse@nicira.com>" header w=
hen
> I sent it, my bad, sorry !

No problem, I have that in the patch header already :)

thanks,

greg k-h
