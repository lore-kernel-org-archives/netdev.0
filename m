From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Wed, 28 Oct 2015 16:05:23 +0100
Message-ID: <20151028150523.GQ26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
 <20150923162650.148fe95b@urahara>
 <bc9cacb94de24857a7d9e13960bfae56@HQ1WP-EXMB11.corp.brocade.com>
 <20150924151630.28129cdb@urahara>
 <5604E357.9000802@gmx.net>
 <56308253.2060608@gmx.net>
 <20151028082815.GO26876@orbit.nwl.cc>
 <5630B828.6070500@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:33875 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022AbbJ1PFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 11:05:25 -0400
Content-Disposition: inline
In-Reply-To: <5630B828.6070500@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 12:57:28PM +0100, Matthias Tafelmeier wrote:
> >> Those resentments were related to the patchsets complexity and
> >> size.
> >=20
> > I didn't see any problem with that in the first place. It is indeed
> > a big change, achieving something like that without a big patch set
> > is unlikely.
> >=20
>=20
> Fine, I was just repounding that since Steven Hemminger raised that.
> My reasoning here is that I just don't want to kick off restarting
> work whith objections still in the minds =E2=80=93 since we are alrea=
dy at V7
> now.

Yeah, sorry for not having looked into this earlier. Also, I neither
have nor claim any power of veto. Apart from that, I'm not against this
patch series in general, just trying to help raise it's quality a bit.
Eventually, we don't set anything in stone so everything can be
fixed/improved later on. Except Git history of course, which is
important to get right in relation to bisecting.

Cheers, Phil
