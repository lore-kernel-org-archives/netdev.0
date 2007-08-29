From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 4/5] Net: ath5k, license is GPLv2
Date: Wed, 29 Aug 2007 19:28:58 +0100
Message-ID: <20070829192858.75aa6542@the-village.bc.nu>
References: <2713029743177393055@pripojeni.net>
	<7515194658758617@pripojeni.net>
	<20070828171155.GC29343@infradead.org>
	<3208.1188408545@turing-police.cc.vt.edu>
	<9e4733910708291101i3783a8b1l38f0d5cfb0c2863d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	"Christoph Hellwig" <hch@infradead.org>,
	"Jiri Slaby" <jirislaby@gmail.com>, linville@tuxdriver.com,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "Jon Smirl" <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:41002 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750734AbXH2SVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 14:21:11 -0400
In-Reply-To: <9e4733910708291101i3783a8b1l38f0d5cfb0c2863d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > to remove the BSD/other license.   Jiri can release *his* code as GPLv2
> > only, but I suspect the files as a whole really should be dual BSD/GPLv2,
> > due to the numerous other stakeholders in those files.
> 
> This mess has been occurring in the kernel for years. The DRM graphics
> drivers are used in both BSD and Linux. It is quite easy to contribute
> something to this code via LKML and think you are doing it under the
> GPL. Doesn't a patch against the kernel have to be GPL? When these
> patches get pulled back into BSD and distributed with it, did BSD get
> infected with the GPL? AFAIK this has never been legally sorted out.

I'm not aware anyone has felt it needed "sorting out". Its not exactly
complicated.

	BSD non advertising is compatible with GPL

The GPL says:
	"when you distribute the same sections as part of a whole which
	is a work based on the Program, the distribution of the whole
	must be on the terms of this License, "

The BSD license doesn't conflict with that

The GPL (and copyright law also say)

"If identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to ..."

All a bit irrelevant anyway as Ath5K code (not the .h file) say:

 * Alternatively, this software may be distributed under the terms of the
 * GNU General Public License ("GPL") version 2 as published by the Free
 * Software Foundation.

So Jiri is choosing to distribute it under the GPL, and with his changes
GPL only.

So whats the problem ?

