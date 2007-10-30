From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Tue, 30 Oct 2007 15:08:53 -0400
Message-ID: <47278145.8010002@hp.com>
References: <4727647A.30706@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Brown <neilb@suse.de>,
	Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:36095 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbXJ3TJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 15:09:35 -0400
In-Reply-To: <4727647A.30706@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aur=E9lien Charbon wrote:
> Here is a second missing part of the IPv6 support in NFS server code=20
> concerning knfd syscall interface.
> It updates write_getfd and write_getfd to accept IPv6 addresses.
>=20
> Applies on a kernel including ip_map cache modifications

Both patches still have bugs, I think the patch I sent yesterday fixed=20
them all, so I would recommend using that instead.  Of course Neil's=20
comment possibly trumps all that anyways...

-Brian
