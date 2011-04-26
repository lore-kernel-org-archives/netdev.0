From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Tue, 26 Apr 2011 20:07:16 +0100
Message-ID: <1303844836.2850.6.camel@bwh-desktop>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
	 <1303799597.2747.214.camel@edumazet-laptop>
	 <20110425.235600.104065244.davem@davemloft.net>
	 <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com>
	 <1303834864.3358.58.camel@edumazet-laptop>
	 <43F901BD926A4E43B106BF17856F0755018DC497F8@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55348 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab1DZTHU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 15:07:20 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755018DC497F8@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-26 at 09:24 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Tuesday, April 26, 2011 9:21 AM
> > To: Rose, Gregory V
> > Cc: David Miller; netdev@vger.kernel.org; bhutchings@solarflare.com
> > Subject: RE: [RFC PATCH] netlink: Increase netlink dump skb message=
 size
> >=20
> > Le mardi 26 avril 2011 =C3=A0 09:12 -0700, Rose, Gregory V a =C3=A9=
crit :
> >=20
> > > I'm fine with however you folks want to approach this, just give =
me some
> > direction.
> >=20
> > I would just try following patch :
>=20
> I'll test it out, it's certainly a lot simpler.  Perhaps I was gettin=
g a bit too fancy.
>=20
> Ben would want to make sure it works for 127 VFs, my device does 63.

I haven't been working on SR-IOV myself so I'll pass this on to a
colleague.  Thanks, Eric.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

