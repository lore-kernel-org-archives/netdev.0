From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
 driver.
Date: Sun, 11 Oct 2009 09:40:54 +0200
Message-ID: <4AD18C06.8040002@gmail.com>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>	<1253662724-16497-2-git-send-email-tomas.winkler@intel.com>	<1ba2fa240910100238s709c31d3s6cb612f502b1086f@mail.gmail.com> <20091010.185852.133969433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091010.185852.133969433.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
>=20
> If it's not in netdev patchwork, I don't plan to add it.
>=20
> If it is in patchwork, then it's in my backlog and I'll get to it.
>=20
> People should never really have to ask me these questions, that's one
> of the main points of:
>=20
> 	http://patchwork.ozlabs.org/project/netdev/list/
>=20
> You can always see there what's "pending".


Me wondering if this information could be put in MAINTAINERS or Documen=
tation/ something...

I know it only because I caught one of your answer a while ago :)

Either a per project info, or a global ref to http://patchwork.ozlabs.o=
rg/

diff --git a/MAINTAINERS b/MAINTAINERS
index e1da925..18244ad 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3654,6 +3654,7 @@ NETWORKING [GENERAL]
 M:	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
 L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://www.linuxfoundation.org/en/Net
+W:	http://patchwork.ozlabs.org/project/netdev/list/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
 S:	Maintained
 F:	net/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
