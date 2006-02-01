From: Danny van Dyk <kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: Re: [GIT PULL] bcm43xx: Update B6PHY initialization
Date: Wed, 1 Feb 2006 19:54:51 +0100
Message-ID: <200602011954.52325.kugelfang@gentoo.org>
References: <43DFFB6C.9050907@gentoo.org> <200602011051.00973.kugelfang@gentoo.org> <200602011455.34307.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "John Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
In-Reply-To: <200602011455.34307.mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Content-Disposition: inline
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

John,

> On Wednesday 01 February 2006 10:51, Danny van Dyk wrote:
> > John, please
> >
> > git pull rsync://pitr.amd64.dev.gentoo.org/kugelfang/wireless-2.6.git
> >
> > which will provide this changeset:
> >
> > Danny van Dyk:
> >       [bcm43xx] Sync bcm43xx_phy_initb6() with specs
>
> Danny, _please_ make sure to apply patches to the softmac _and_ the dscape
> branch. Otherwise patches will get lost.
> It is very important to keep both branches in sync.

I just added the very same patch to the dscape-all branch in my repo. Please

    git pull rsync://pitr.amd64.dev.gentoo.org/kugelfang/wireless-2.6.git

I don't post the patch again, as it is really the same as the previously sent 
patch

When applying it, I noticed that the dscape branch's bcm43xx is differently 
named than the softmac branch's. Why ? :-)

Danny
-- 
Danny van Dyk <kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Gentoo/AMD64 Project, Gentoo Scientific Project
