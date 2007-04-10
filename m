From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] bridge update for 2.6.22
Date: Tue, 10 Apr 2007 13:23:55 -0700 (PDT)
Message-ID: <20070410.132355.63995586.davem@davemloft.net>
References: <20070409135552.5eee2bc8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030528AbXDJUXz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 16:23:55 -0400
In-Reply-To: <20070409135552.5eee2bc8@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 9 Apr 2007 13:55:52 -0700

> Here is an update to bridging code for net-2.6.22
>=20
> The following changes since commit 532122caf3f7573760c5ec523bc3be1460=
6bb8f2:
>   Ilpo J=E4rvinen (1):
>         [TCP]: Simplify LOST marker code
>=20
> are found in the git repository at:
>=20
>   master.kernel.org:/pub/scm/linux/kernel/git/shemminger/bridge-2.6.2=
2.git
>=20
> Akinobu Mita (1):
>       bridge: check kmem_cache_create() error
>=20
> Stephen Hemminger (7):
>       bridge: eliminate call by reference
>       bridge: don't route packets while learning
>       bridge: simpler hash with salt
>       bridge: add sysfs hook to flush forwarding table
>       bridge: add support for user mode STP
>       bridge: change when netlink events go to STP
>       bridge: allow changing hardware address to any valid address

Pulled, thanks a lot Stephen.
