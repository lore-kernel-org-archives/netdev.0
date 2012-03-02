From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_STREAM performance regression on commit b3613118
Date: Fri, 02 Mar 2012 04:28:15 -0800
Message-ID: <1330691295.2469.1.camel@edumazet-laptop>
References: <1329472239.2861.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120217.133327.1178765872497293871.davem@davemloft.net>
	 <1330656317.21053.1411.camel@debian>
	 <20120301.220743.2174015405223036036.davem@davemloft.net>
	 <1330670277.21053.1448.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, feng.tang@intel.com,
	linux-kernel@vger.kernel.org, tim.c.chen@intel.com,
	ying.huang@intel.com, netdev@vger.kernel.org
To: Alex Shi <alex.shi@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330670277.21053.1448.camel@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 02 mars 2012 =C3=A0 14:37 +0800, Alex Shi a =C3=A9crit :
> On Thu, 2012-03-01 at 22:07 -0500, David Miller wrote:
> > From: Alex Shi <alex.shi@intel.com>
> > Date: Fri, 02 Mar 2012 10:45:17 +0800
> >=20
> > > Add CC to tang feng, He is working on this issue.=20
> >=20
> > Is he?  I'm pretty sure this is due to the TCP receive window growi=
ng
> > issue Eric Dumazet, Neal Cardwell and I are discussing in the threa=
d
> > starting at:
> >=20
> > http://marc.info/?l=3Dlinux-netdev&m=3D132916352815286&w=3D2
>=20
> That's great!=20
> May my language make you confusing. Actually, Feng is doing
> investigation on this issue. Since you fund out the reason, it saved =
his
> work. :)=20
>=20

Actually it would be great if you or Feng could post the exact tests
done and numbers so that we can make sure this is the tracked issue.

Thanks
