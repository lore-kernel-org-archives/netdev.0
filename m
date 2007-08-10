From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 GIT state
Date: Thu, 09 Aug 2007 18:27:19 -0700 (PDT)
Message-ID: <20070809.182719.99676246.davem@davemloft.net>
References: <Pine.LNX.4.64.0708091233050.24369@kivilampi-30.cs.helsinki.fi>
	<20070809.041034.93473045.davem@davemloft.net>
	<Pine.LNX.4.64.0708091721030.24369@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58011
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751906AbXHJB1T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 21:27:19 -0400
In-Reply-To: <Pine.LNX.4.64.0708091721030.24369@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 9 Aug 2007 17:40:07 +0300 (EEST)

> Next step:
>=20
> http://www.cs.helsinki.fi/u/ijjarvin/tcp-rebase/after-reorder/
>=20
> ...I put some effort to reorganization and there's the result, please=
=20
> _don't_ take the new SACK block-validator yet as I haven't yet put it=
=20
> under any testing (it's the only difference this reordering of patche=
s=20
> seems to have introduced :-)). The first five commits touch left_out =
(4=20
> latest fix bug and "flaws" I made in the first commit), I could combi=
ne=20
> them into a single one if you want to.

I applied everything up until the SACK validator to net-2.6.24

Thanks for doing all of this merging work, I very much appreciate
it.

> ...Notice that part of the next step includes work that hasn't yet be=
en=20
> posted to netdev at all (was from my not yet submitted wip portion of=
=20
> it). Would you prefer me to post them using the usual procedure?

Everything I hit today which had not been posted before was trivial
fix or a reasonable small cleanup.

Why don't you just post the patches to the list one-by-one from
now on so we can review them in parallel with merging into
net-2.6.24?

Thanks again Ilpo!
