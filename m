From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2009-12-18
Date: Sun, 20 Dec 2009 22:07:38 -0500
Message-ID: <20091221030738.GA2398@tuxdriver.com>
References: <20091218211945.GC2828@tuxdriver.com>
 <20091220.001736.189688434.davem@davemloft.net>
 <20091220133800.GA4700@tuxdriver.com>
 <20091220.182910.226760127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756573AbZLUDME@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091220.182910.226760127.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 20, 2009 at 06:29:10PM -0800, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Sun, 20 Dec 2009 08:38:00 -0500
>=20
> > On Sun, Dec 20, 2009 at 12:17:36AM -0800, David Miller wrote:
> >> From: "John W. Linville" <linville@tuxdriver.com>
> >> Date: Fri, 18 Dec 2009 16:19:45 -0500
> >>=20
> >> > Please let me know if there are problems!
> >>=20
> >> Your tree is based upon Linus's not net-2.6
> >> so when I pulled I got a lot of unrelated
> >> commits.
> >>=20
> >> Please fix this, thanks.
> >=20
> > It's based on 2.6.33-rc1.  Are you not going to pull that into net-=
2.6?
>=20
> Why in the world should I?  There are no conflicts to resolve
> that I know of.
>=20
> And if there are no conflicts to resolve, pulling in Linus's
> tree just makes future pulls into his tree more ugly.
>=20
> This is pretty standard practice, but in any event you shouldn't ever
> care.
>=20
> You should simply always work against net-2.6, there is no reason to
> work against any other tree.
>=20
> This is a pretty fundamental thing, I don't know why you based agains=
t
> Linus's tree instead of net-2.6.  Now you have to rebase already :-/

My mistake!  For some reason I just thought that pulling from -rc1 was
your normal practice -- now I can't figure what gave me that idea...

Anyway, might as well have one more rebase now.  I'll straighten-out
my trees tomorrow morning and resubmit.

John
--=20
John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world will =
need a hero, and you
linville@tuxdriver.com =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be all =
we have. =A0Be ready.
