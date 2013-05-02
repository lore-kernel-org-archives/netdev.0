From: Chen Gang <gang.chen@asianux.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 02 May 2013 09:25:39 +0800
Message-ID: <5181C093.3010301@asianux.com>
References: <20130430122423.ab57c82604f13f6773ef4aeb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alan Ott <alan@signal11.us>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130430122423.ab57c82604f13f6773ef4aeb@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013=E5=B9=B404=E6=9C=8830=E6=97=A5 10:24, Stephen Rothwell wrote:
> Hi all,
>=20
> Today's linux-next merge of the net-next tree got a conflict in
> net/mac802154/mac802154.h between commit 2c1bbbffa0b6 ("net: mac80215=
4:
> comparision issue of type cast, finding by EXTRA_CFLAGS=3D-W") from t=
he net
> tree and commit 7dd43d356e73 ("mac802154: Do not try to resend failed
> packets") from the net-next tree.
>=20
> I fixed it up (see below) and can carry the fix as necessary (no acti=
on
> is required).

Thanks

--=20
Chen Gang

Asianux Corporation
