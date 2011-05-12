From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Thu, 12 May 2011 23:15:53 +0200
Message-ID: <1305234953.2831.2.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
	 <1303878240.2699.41.camel@edumazet-laptop>
	 <1303878771.2699.44.camel@edumazet-laptop>
	 <201104271352.00601.maxi@daemonizer.de>
	 <20110512211033.GA3468@dev1756.snc6.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110512211033.GA3468@dev1756.snc6.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 12 mai 2011 =C3=A0 14:10 -0700, Arun Sharma a =C3=A9crit :
> On Wed, Apr 27, 2011 at 01:51:59PM +0200, Maximilian Engelhardt wrote=
:
> >=20
> > thank you for this information. I updated the kernel of the affecte=
d server to=20
> > version 2.6.38.4 yesterday. I'll report when there are still crashe=
s, but it=20
> > might take a while, as in the past they only happened within the in=
terval of=20
> > weeks to month.
>=20
> I've seen this panic on 2.6.38.y as well. It's rare (< 1%), but the
> panic consistently happens at the same place.
>=20
> Are any of the inetpeer.c commits in the 2.6.39 tree, which are not i=
n -stable yet,
> good candidates to try?
>=20

Probably not.

What gives slub_nomerge=3D1   for you ?
