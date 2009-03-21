From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] e100: add support for 82552 10/100 adapter
Date: Sat, 21 Mar 2009 13:25:32 -0700 (PDT)
Message-ID: <20090321.132532.113692184.davem@davemloft.net>
References: <20090319104236.11320.25733.stgit@lost.foo-projects.org>
	<9929d2390903190407l4796577bkd7163c8c1778dc10@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43156
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753819AbZCUUZp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 16:25:45 -0400
In-Reply-To: <9929d2390903190407l4796577bkd7163c8c1778dc10@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Mar 2009 04:07:14 -0700

> On Thu, Mar 19, 2009 at 3:42 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Bruce Allan <bruce.w.allan@intel.com>
> >
> > This patch enables support for the new Intel 82552 adapter (new PHY=
 paired
> > with the existing MAC in the ICH7 chipset). =A0No new features are =
added to
> > the driver, however there are minor changes due to updated register=
s and a
> > few workarounds for hardware errata.
> >
> > Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>=20
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
