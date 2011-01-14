From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH resend] Bluetooth: l2cap: fix misuse of logical
 operation in place of bitop
Date: Fri, 14 Jan 2011 14:30:56 -0200
Message-ID: <20110114163056.GA3736@vigoh>
References: <1295013584-15592-1-git-send-email-dsterba@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
To: David Sterba <dsterba-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1295013584-15592-1-git-send-email-dsterba-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

* David Sterba <dsterba-AlSwsSmVLrQ@public.gmane.org> [2011-01-14 14:59:44 +0100]:

> CC: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> CC: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> CC: Jo=E3o Paulo Rechi Vita <jprvita-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> Signed-off-by: David Sterba <dsterba-AlSwsSmVLrQ@public.gmane.org>
> ---
>=20
> Andrew, this has not been picked up by maintainers since 27.12., plea=
se consider it for -mm.
>=20
>  net/bluetooth/l2cap.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

I'm taking care of this. Sorry for the delay, I've been away a bit.
Patch is now applied to Bluetooth tree. Thanks.

--=20
Gustavo F. Padovan
http://profusion.mobi
