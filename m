From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: Bug#532152: Request for help with iproute2 bugs.
Date: Mon, 07 Dec 2009 07:50:04 +0100
Message-ID: <1260168604.9431.52.camel@amd64.fatal.se>
References: <20091123103742.GA14713@amd64.fatal.se>
	 <20091203010824.GA19810@verge.net.au>  <20091207034724.GB419@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Simon Horman <horms@verge.net.au>, 532152@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy1.bredband.net ([195.54.101.71]:54413 "EHLO
	proxy1.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755615AbZLGGs6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 01:48:58 -0500
Received: from ipb2.telenor.se (195.54.127.165) by proxy1.bredband.net (7.3.140.3)
        id 4AD3E1C001823F49 for netdev@vger.kernel.org; Mon, 7 Dec 2009 07:49:01 +0100
In-Reply-To: <20091207034724.GB419@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On m=C3=A5n, 2009-12-07 at 14:47 +1100, Simon Horman wrote:
> On Thu, Dec 03, 2009 at 12:08:27PM +1100, Simon Horman wrote:
> > On Mon, Nov 23, 2009 at 11:37:42AM +0100, Andreas Henriksson wrote:
> > > http://bugs.debian.org/532152 - incorrectly enumerates existing a=
ddresses.
> > >   iproute: 'ip addr flush' exits with error on first try
> >=20
> > I've taken a stab at this one.
> >=20
>=20
> Any feedback?


Looks good to me! Thanks for taking care of this.

Hopefully Stephen does his next round of reviews soon so this (and othe=
r
pending patches) gets applied. We'll have to wait and see....

--=20
Regards,
Andreas Henriksson
