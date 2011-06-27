From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFT PATCH v3 00/12] Cleanup and extension of netdev features
Date: Mon, 27 Jun 2011 16:21:59 +0200
Message-ID: <20110627142159.GB26244@rere.qmqm.pl>
References: <cover.1308758435.git.mirq-linux@rere.qmqm.pl>
 <4E0276A0.8010802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60241 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104Ab1F0OWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 10:22:01 -0400
Content-Disposition: inline
In-Reply-To: <4E0276A0.8010802@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 04:11:28PM -0700, Ben Greear wrote:
> On 06/22/2011 09:04 AM, Micha=C5=82 Miros=C5=82aw wrote:
> >v3 of a feature handling cleanup and extension series. For testing, =
you
> >might want user-space ethtool patched with:
> >
> >http://patchwork.ozlabs.org/patch/96374/
> There is a typo in one of those patches:
>   CC      fs/quota/netlink.o
> /home/greearb/git/net-next-2.6/net/core/dev.c: In function =E2=80=98_=
_netdev_update_features=E2=80=99:
> /home/greearb/git/net-next-2.6/net/core/dev.c:5288: warning: too many=
 arguments for format
>   CC      net/core/ethtool.o
> 	netdev_dbg(dev, "Features changed: %pNF -> pNF\n",
> 		&dev->features, &features);

Noted for next version.

Best Regards,
Micha=C5=82 Miros=C5=82aw=20
