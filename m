From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/2] wireless: Make and use const struct ieee80211_channel
Date: Fri, 6 May 2011 09:19:22 -0400
Message-ID: <20110506131922.GA2252@tuxdriver.com>
References: <cover.1304054543.git.joe@perches.com>
 <20110505184934.GB3005@tuxdriver.com>
 <1304634107.1788.171.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	orinoco-users@lists.sourceforge.net,
	orinoco-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304634107.1788.171.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2011 at 03:21:47PM -0700, Joe Perches wrote:
> On Thu, 2011-05-05 at 14:49 -0400, John W. Linville wrote:
> > These patches generated a lot of warnings in net/mac80211.  Did you
> > actually build them?
>=20
> Yes.
>=20
> Did you apply patch 1/2 first?
> It's a dependent patch.

That's the one that cause most of the warnings...

--=20
John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world will =
need a hero, and you
linville@tuxdriver.com =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be all =
we have. =A0Be ready.
