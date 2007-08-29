From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 4/5] Net: ath5k, license is GPLv2
Date: Wed, 29 Aug 2007 20:45:29 +0100
Message-ID: <20070829204529.66ce1bcb@the-village.bc.nu>
References: <2713029743177393055@pripojeni.net>
	<7515194658758617@pripojeni.net>
	<20070828171155.GC29343@infradead.org>
	<3208.1188408545@turing-police.cc.vt.edu>
	<9e4733910708291101i3783a8b1l38f0d5cfb0c2863d@mail.gmail.com>
	<20070829192858.75aa6542@the-village.bc.nu>
	<9e4733910708291233h3c4022a9n6e46733c5c50e222@mail.gmail.com>
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
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:35395 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755074AbXH2Tiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 15:38:46 -0400
In-Reply-To: <9e4733910708291233h3c4022a9n6e46733c5c50e222@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Aren't patches made against the kernel GPL'd if the author doesn't
> explicitly grant them more liberal BSD license in addition?

That would be the normal assumption.

> The problem then comes in taking the patches that were only made
> available against GPL code and reshipping them under the BSD license
> without the author explicitly agreeing to this.
> 
> What if a patch spans both code that is pure GPL and code imported
> from BSD, how do you license it?

See the acpi codebase for a worked example.

Alan
