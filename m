From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/3] b43: logging cleanups
Date: Thu, 24 Jun 2010 12:40:32 -0700
Message-ID: <1277408432.1654.80.camel@Joe-Laptop.home>
References: <cover.1276988387.git.joe@perches.com>
	 <20100624185339.GC2368@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefano Brivio <stefano.brivio@polimi.it>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Larry.Finger@lwfinger.net,
	mb@bu3sch.de, zajec5@gmail.com
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1283 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752Ab0FXTkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 15:40:36 -0400
In-Reply-To: <20100624185339.GC2368@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-24 at 14:53 -0400, John W. Linville wrote:
> On Sat, Jun 19, 2010 at 04:30:08PM -0700, Joe Perches wrote:
> > Just some small cleanups
> > Joe Perches (3):
> >   drivers/net/wireless/b43: Use local ratelimit_state
> >   drivers/net/wireless/b43: Logging cleanups
> >   drivers/net/wireless/b43: Rename b43_debug to b43_debugging
> Any of the b43 guys want to express an opinion on these?

Stefano, are you active here?
Your last ack for b43 was Feb 2008.
There have been 400+ commits to b43 without your ack.

Should your name be moved from MAINTAINERS to CREDITS?

$ ./scripts/get_maintainer.pl --rolestats -f drivers/net/wireless/b43/
Stefano Brivio <stefano.brivio@polimi.it> (maintainer:B43 WIRELESS DRIV=
ER)
"John W. Linville" <linville@tuxdriver.com> (maintainer:NETWORKING [WIR=
EL...,commit_signer:204/240=3D85%)
"Rafa=C5=82 Mi=C5=82ecki" <zajec5@gmail.com> (commit_signer:83/240=3D35=
%)
"G=C3=A1bor Stefanik" <netrolller.3d@gmail.com> (commit_signer:44/240=3D=
18%)
Michael Buesch <mb@bu3sch.de> (commit_signer:39/240=3D16%)
Larry Finger <Larry.Finger@lwfinger.net> (commit_signer:13/240=3D5%)
linux-wireless@vger.kernel.org (open list:B43 WIRELESS DRIVER)
netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
linux-kernel@vger.kernel.org (open list)


