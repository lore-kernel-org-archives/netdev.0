From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Cbe-oss-dev] [PATCH 0/15] spidernet driver bug fixes
Date: Wed, 13 Jun 2007 22:52:45 +0200
Message-ID: <200706132252.46314.arnd@arndb.de>
References: <20070607191707.GA7904@austin.ibm.com> <1873ace6a10b1a4c022d00ebb23df5b5@kernel.crashing.org> <46703F50.2000202@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	netdev@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>
To: cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:63200 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbXFMUw5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 16:52:57 -0400
In-Reply-To: <46703F50.2000202@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 June 2007, Jeff Garzik wrote:
> Segher Boessenkool wrote:
> >> I wish there was a git option to "just make my shit look like the
> >> remote, dammit!" =A0The above is the "easiest" way I know how to d=
o that.
> >=20
> > git-fetch -f remote:local ?
>=20
> If that works... great :) =A0Much better than what I described.

It works as long as you are not on branch 'local', but in that case
you can do 'git-fetch -f remote:local2' or something.

	Arnd <><
