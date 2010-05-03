From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [GIT PULL] first round of vhost-net enhancements for net-next
Date: Tue, 4 May 2010 01:20:23 +0300
Message-ID: <20100503222022.GC16181@redhat.com>
References: <20100503213244.GA16006@redhat.com> <20100503.150729.00474027.davem@davemloft.net> <20100503.150829.254849182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100503.150829.254849182.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 03, 2010 at 03:08:29PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 03 May 2010 15:07:29 -0700 (PDT)
>=20
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> > Date: Tue, 4 May 2010 00:32:45 +0300
> >=20
> >> The following tree includes a couple of enhancements that help vho=
st-net.
> >> Please pull them for net-next. Another set of patches is under
> >> debugging/testing and I hope to get them ready in time for 2.6.35,
> >> so there may be another pull request later.
> >=20
> > Pulled, thanks.
>=20
> Nevermind, reverted.
>=20
> Do you even compile test what you send to people?
>=20
> drivers/net/macvtap.c: In function =E2=80=98macvtap_ioctl=E2=80=99:
> drivers/net/macvtap.c:713: warning: control reaches end of non-void f=
unction
>=20
> You're really batting 1000 today Michael...

Ouch. Should teach me not to send out stuff after midnight. Sorry about
the noise.

--=20
MST
