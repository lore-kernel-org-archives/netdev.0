From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [RFC 0/3] RDMA: Add netlink infrastructure
Date: Fri, 13 May 2011 09:18:42 -0700
Message-ID: <1305303525-11113-1-git-send-email-roland@kernel.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>

Hi,

Here are the highlights of a patch series adding support for getting
information on active RDMA connections via netlink.  I would really
appreciate it if netlink experts could take a look and make sure we
are doing this the right way and using a suitably extensible
structure.

I'm by no means particularly knowledgeable about netlink, so although
the RDMA side of things looks OK to me, I hope we can get some level
of review of the netlink side of things; the changelog for patch 2/3
tries to explain the messages we're using.

The full series based on 2.6.39-rc7 is also available at:

    git://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git netlink

Thanks!
  Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
