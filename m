From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net 1/1] r8169: fix offloaded tx checksum for small
 packets.
Date: Mon, 10 Jun 2013 23:54:07 +0200
Message-ID: <20130610215407.GD30891@electric-eye.fr.zoreil.com>
References: <20130518112446.GA21268@electric-eye.fr.zoreil.com>
 <5197936C.6090607@googlemail.com>
 <51B5B48A.5040807@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40447 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab3FJVy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 17:54:26 -0400
Content-Disposition: inline
In-Reply-To: <51B5B48A.5040807@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger Hoffst=C3=A4tte <holger.hoffstaette@googlemail.com> :
[...]
> As far as I can tell this patch is still not in -stable 3.9.5 or queu=
ed
> up for the next iteration.

It is queued in davem's stable bundle, see:

http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*

I'll propagate it once it reaches -stable.

--=20
Ueimor
