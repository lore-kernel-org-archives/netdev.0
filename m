From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Sat, 24 Dec 2011 11:22:12 +0100
Message-ID: <1324722132.3860.15.camel@deadeye>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37744 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753041Ab1LXKWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2011 05:22:19 -0500
In-Reply-To: <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-23 at 18:58 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/12/23 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> > From: Don Skidmore <donald.c.skidmore@intel.com>
> >
> > Some of our adapters have thermal data available, this patch export=
s this
> > data via a read-only sysfs interface.
>=20
> Just curious: can't this use the hwmon subsystem to be consistent wit=
h
> other system monitoring devices?

That would certainly be the proper way to expose this...

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
