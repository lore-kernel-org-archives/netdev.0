From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state
 change handling
Date: Sun, 25 Jan 2015 04:49:00 +0200
Message-ID: <20150125024900.GA6621@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
 <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux>
 <20150121162025.2933.13836@shannon>
 <54C02F4B.80206@pengutronix.de>
 <20150122101447.25198.24222@shannon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andri Yngvason <andri.yngvason@marel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:38205 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbbAYCtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 21:49:07 -0500
Content-Disposition: inline
In-Reply-To: <20150122101447.25198.24222@shannon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 10:14:47AM +0000, Andri Yngvason wrote:
> Quoting Marc Kleine-Budde (2015-01-21 22:59:23)
> > On 01/21/2015 05:20 PM, Andri Yngvason wrote:
> > > Marc, could you merge the "move bus_off++" patch before you merge this so that I
> > > won't have to incorporate this patch-set into it?
> > 
> > ...included in the lastest pull-request to David. Use
> > tags/linux-can-next-for-3.20-20150121 of the can-next repo as you new base.
> > 
> 
> Thanks!
>

I guess I'll re-base my next submission over this tag too.
Nothing in the new 5 patches is substantial enough to be
included in the current kernel release.

Thanks!
Darwish
