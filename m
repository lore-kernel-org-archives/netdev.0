From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: ethtool needs a new maintainer
Date: Mon, 27 Jun 2016 09:51:47 -0400
Message-ID: <20160627135146.GB6864@tuxdriver.com>
References: <1466956772.2551.6.camel@decadent.org.uk>
 <1466957501.2551.17.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35782 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbcF0OAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:00:18 -0400
Content-Disposition: inline
In-Reply-To: <1466957501.2551.17.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 26, 2016 at 06:11:41PM +0200, Ben Hutchings wrote:
> I've become steadily less enthusiastic and less responsive as a
> maintainer over the past year or so. =A0I no longer work on networkin=
g
> regularly, so it takes a lot more time to get into the right state of
> mind to think about ethtool code, while I have other demands on my ti=
me
> that tend to take priority.
>=20
> So, I would like to find a new maintainer to take over as soon as
> possible. =A0Ideally the new maintainer would have previous contribut=
ions
> to ethtool and an existing account on kernel.org so that they can pus=
h
> to the git repository and the home page. =A0But neither of those is
> essential. =A0Please reply if you're interested.

I would like to take this responsibility. My previous contributions
to ethtool are meager, but I think my skills and interests are suited
to the task.  Plus, I already have a kernel.org account... :-)

> I was thinking of adding a TODO file to the repository, but it's real=
ly
> for the new maintainer to decide what to do. =A0So here's my list as =
a
> suggestion:
>=20
> * Add regression test coverage for all sub-commands with complex logi=
c
>=20
> * Internationalise output and error messages
>=20
> * Build a libethtool that handles all the API quirks and fallbacks fo=
r
> =A0 old kernel versions.=A0=A0This might help people writing language
> =A0 bindings or other utilities that use the ethtool API.
>=20
> * Provide a 'cleaned up' ethtool (under some other name) that has:
> =A0 - More conventional sub-command syntax, i.e. no '-'/'--' prefix
> =A0 - More consistent output formatting

That seems like a reasonable start for a TODO list. I'll bet there
are a few people out there with other suggestions as well...?

Anyway, I would be happy to take-on the job of ethtool maintainer,
and I look forward to getting back into a more concrete role within
the community. Any objections?

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
