From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Add IP1000A Driver
Date: Wed, 12 Sep 2007 09:34:48 +0200
Message-ID: <20070912093448.0a8ee1f0@oldman>
References: <AA68EB0EBA29BA40A06B700C33343EEF0190124E@fileserver.icplus.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	jesse@icplus.com.tw
To: =?UTF-8?B?6buD5bu66IiILUplc3Nl?= <Jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51599 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753393AbXILHfE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 03:35:04 -0400
In-Reply-To: <AA68EB0EBA29BA40A06B700C33343EEF0190124E@fileserver.icplus.com.tw>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 13:35:43 +0800
=E9=BB=83=E5=BB=BA=E8=88=88-Jesse <Jesse@icplus.com.tw> wrote:

>=20
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@linux-foundation.org]=20
> > Sent: Tuesday, September 11, 2007 10:42 PM
> > To: Jesse Huang
> > Cc: jeff@garzik.org; akpm@linux-foundation.org; netdev@vger.kernel.=
org;
> jesse@icplus.com.tw
> > Subject: Re: [PATCH] Add IP1000A Driver
> >
> >
> > Who will be listed as maintainer of this device?
> > A good way to show that is to add an entry to MAINTAINERS file.
>=20
>=20
> Ok, Should I generate a patch to modify MAINTAINERS file?

Yes, can be included with patch or separate, it doesn't matter.

>=20
> > + * Current Maintainer:
> > + *
> > + *   Sorbica Shieh.
> > + *   10F, No.47, Lane 2, Kwang-Fu RD.
> > + *   Sec. 2, Hsin-Chu, Taiwan, R.O.C.
> > + *   http://www.icplus.com.tw
> > + *   sorbica@icplus.com.tw
> > + */
>=20
> > Names only, no physical addresses please.
>=20
> Should I remove those two lins?
> 10F, No.47, Lane 2, Kwang-Fu RD.
> Sec. 2, Hsin-Chu, Taiwan, R.O.C.

It is your option, but many times people and companies move locations
and this gets out of date.
