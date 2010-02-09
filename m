From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: manual merge of the net tree with the
 wireless-current tree
Date: Mon, 8 Feb 2010 22:20:44 -0500
Message-ID: <20100209032044.GA3397@tuxdriver.com>
References: <20100209132444.d90b48a6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100209132444.d90b48a6.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 09, 2010 at 01:24:44PM +1100, Stephen Rothwell wrote:
> Hi all,
>=20
> Today's linux-next merge of the net tree got a conflict in
> net/mac80211/scan.c between commit
> c0ce77b8323c1a0d4eeef97caf16c0ea971222a9 ("mac80211: fix deferred
> hardware scan requests") from the wireless-current tree and commit
> af6b63741cc4e4dfd575d06beb333b11a8a6e0c0 ("mac80211: generalise work
> handling") from the net tree.
>=20
> I resolved this the same way it is resolved in the merge of the
> wireless-current tree into the wireless tree.

Maybe it would make sense to pull the wireless trees _before_ the
greater net trees?  That way you can get the benefit of my merge
conflict resolutions automatically.

John
--=20
John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world will =
need a hero, and you
linville@tuxdriver.com =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be all =
we have. =A0Be ready.
