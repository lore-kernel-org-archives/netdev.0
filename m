From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v6 7/9] forcedeth: implement ndo_get_stats64()
 API
Date: Thu, 17 Nov 2011 18:47:09 +0100
Message-ID: <1321552029.2751.88.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <cover.1321481064.git.david.decotigny@google.com>
	 <185a0f33c69ff07e8fe3482828b368371420bf47.1321481064.git.david.decotigny@google.com>
	 <1321511678.3274.30.camel@edumazet-laptop>
	 <CAG88wWbiwVKUVtQxV=FzBTfaCngeGYXL9M_00NQKCgbEqic4-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG88wWbiwVKUVtQxV=FzBTfaCngeGYXL9M_00NQKCgbEqic4-w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 17 novembre 2011 =C3=A0 09:39 -0800, David Decotigny a =C3=A9c=
rit :
> On Wed, Nov 16, 2011 at 10:34 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > You should use the _bh variants.
>=20
> Oooops. It's unforgivable: the sky2 implementation you mentioned in a
> previous message was the simple and right model to follow. Grrrrrr.
> Sending a fix shortly.
>=20

Dont worry, we all did the exact same mistakes :)
