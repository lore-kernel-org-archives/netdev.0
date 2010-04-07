From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Wed, 07 Apr 2010 15:31:23 +0200
Message-ID: <1270647083.8141.0.camel@edumazet-laptop>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
	 <1270502993.9013.36.camel@edumazet-laptop>
	 <20100406.195204.165441511.davem@davemloft.net>
	 <b8be47d5-5db7-4e72-a45f-94fc54b7f370@VA3EHSMHS036.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, grant.likely@secretlab.ca,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	michal.simek@petalogix.com, jtyner@cs.ucr.edu
To: John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:64199 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757943Ab0DGNba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 09:31:30 -0400
Received: by bwz1 with SMTP id 1so812139bwz.21
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 06:31:28 -0700 (PDT)
In-Reply-To: <b8be47d5-5db7-4e72-a45f-94fc54b7f370@VA3EHSMHS036.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 avril 2010 =C3=A0 07:25 -0600, John Linn a =C3=A9crit :
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Tuesday, April 06, 2010 8:52 PM
> > To: eric.dumazet@gmail.com
> > Cc: John Linn; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
> grant.likely@secretlab.ca;
> > jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com;
> michal.simek@petalogix.com; jtyner@cs.ucr.edu
> > Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driv=
er
> >=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Mon, 05 Apr 2010 23:29:53 +0200
> >=20
> > > So, I ask, cant you use netdev_alloc_skb_ip_align() in this drive=
r ?
> >=20
> > Thanks to everyone for getting this patch into shape.
> >=20
> > I applied version 4 of the patch to net-next-2.6, thanks!
>=20
> Thanks David, appreciate everyone's help and patience.
>=20

You're welcome ;)

Thanks


