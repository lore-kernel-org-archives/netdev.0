From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH COMMITTED] bluetooth: hci: Fix type of "enable_hs" to
 bool.
Date: Mon, 23 Jan 2012 13:20:26 +0200
Message-ID: <20120123112026.GA18050@x220>
References: <20120122.144654.2252112633629547845.davem@davemloft.net>
 <1327283783.1955.84.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1327283783.1955.84.camel@aeonflux>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

On Mon, Jan 23, 2012, Marcel Holtmann wrote:
> Hi Dave,
>=20
> > net/bluetooth/hci_core.c: In function =E2=80=98__check_enable_hs=E2=
=80=99:
> > net/bluetooth/hci_core.c:2587:1: warning: return from incompatible =
pointer type [enabled by default]
> >=20
> > Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > ---
> >=20
> > I noticed this while validating the build today, committed to 'net'=
=2E
>=20
> and from your subject, I assume you rightfully just applied that patc=
h
> to your tree.
>=20
> I remember that I acked such a patch, but it seems it never made it
> anywhere in the end :(

It's over here:

http://git.kernel.org/?p=3Dlinux/kernel/git/jh/bluetooth-next.git;a=3Dc=
ommitdiff;h=3D174b9000541fdffbdc53cf9464efb1c8a1d777db

Johan
