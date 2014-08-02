From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 2/3] ethtool: Add support for DMA buffer
 settings
Date: Sat, 02 Aug 2014 16:06:10 +0100
Message-ID: <1406991970.30258.47.camel@deadeye.wl.decadent.org.uk>
References: <1406634039-15030-1-git-send-email-_govind@gmx.com>
	 <1406634039-15030-3-git-send-email-_govind@gmx.com>
	 <20140730.175306.483788306179792581.davem@davemloft.net>
	 <1406987782.30258.43.camel@deadeye.wl.decadent.org.uk>
	 <20140802072607.6eec3334@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-86+sJm7eStxdiWm+klH8"
Cc: David Miller <davem@davemloft.net>, _govind@gmx.com,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50707 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754547AbaHBPGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 11:06:24 -0400
In-Reply-To: <20140802072607.6eec3334@haswell.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-86+sJm7eStxdiWm+klH8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-08-02 at 07:26 -0700, Stephen Hemminger wrote:
[...]
> Looks like you just reinvented netlink :-)

Badly? ;-)

> I wish ethtool would die.
> It has fixed size static structures and has no notification mechanism.
>
> If we could just get all the ethtool features into netlink, under IF_LINK
> then most of this could go away.

It doesn't go away, it just stops growing.

I know we've talked about this before and I agree in principle.  *But*
neither you nor anyone else proposed how to get there from here.

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-86+sJm7eStxdiWm+klH8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU9z+Z+e/yOyVhhEJAQp91A//UR78aFdYkO3KPOApZz8DT5TKNwmvHXFG
KyydRhUrR/vJal+sIEZgyPPS+vSnr7YPKQE2Ndyk12oTwY2kMvo44zMyJ446ZyPB
fCOnpXbWPAw4Jrf2RIWPEgvy1ks5UasrzFgv+tWBPrLzMsu3e3aMPNNaMIYNuG/3
MwgRJbmd1ygcltRWMvOkSOHRku/mthQVGlTROJt3/7YutMzSQWC8Eet+r2HNtZO0
arxqDCwVIS/gtg3gG239HQ2KlbB3xAgt/70foEJCFl+D8aJpmzsU4pAgij1/e5En
rEcg9aStxddrTu+fP8whZ7phxV86ygK4rBnh/mIbryaupZWQ58TeNTdyRUULUu2l
t3llgks561SrGqK1kGa5ilq50rYFcz1mml5QVVCVQqLASzV6ZP18SWHcmTI3DJqL
yvjclHdlEm42CBZchuCHeuRbzksY8IH0i/lc/aLud45fsOKnRXJx6976HPkNQaRp
r93ce+pcc/l1QSdpcq4/lJQiZfqvgF7Xlw7ndEmfaDeqxjKb6yRkmZ/1llq+ztz/
PZQn9NCsTK58D4Mo3+tLRpeWJvrSlLk5XzvAYznoMJYyyGFXRctGassTdJ4Ef9lg
8UsIijdjfulfWfK4bf9rHQ/Li4jDgJhcyR2IPXiBMaUjBYFbxo5qtNqTUA1mnl+l
+SeeF5/7bo4=
=TGip
-----END PGP SIGNATURE-----

--=-86+sJm7eStxdiWm+klH8--
