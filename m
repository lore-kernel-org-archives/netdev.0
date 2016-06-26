From: Ben Hutchings <ben@decadent.org.uk>
Subject: ethtool needs a new maintainer
Date: Sun, 26 Jun 2016 18:11:41 +0200
Message-ID: <1466957501.2551.17.camel@decadent.org.uk>
References: <1466956772.2551.6.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9mEvayCk/kgbczWHjqkQ"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58204 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751460AbcFZQLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 12:11:50 -0400
In-Reply-To: <1466956772.2551.6.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9mEvayCk/kgbczWHjqkQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I've become steadily less enthusiastic and less responsive as a
maintainer over the past year or so. =C2=A0I no longer work on networking
regularly, so it takes a lot more time to get into the right state of
mind to think about ethtool code, while I have other demands on my time
that tend to take priority.

So, I would like to find a new maintainer to take over as soon as
possible. =C2=A0Ideally the new maintainer would have previous contribution=
s
to ethtool and an existing account on kernel.org so that they can push
to the git repository and the home page. =C2=A0But neither of those is
essential. =C2=A0Please reply if you're interested.

I was thinking of adding a TODO file to the repository, but it's really
for the new maintainer to decide what to do. =C2=A0So here's my list as a
suggestion:

* Add regression test coverage for all sub-commands with complex logic

* Internationalise output and error messages

* Build a libethtool that handles all the API quirks and fallbacks for
=C2=A0 old kernel versions.=C2=A0=C2=A0This might help people writing langu=
age
=C2=A0 bindings or other utilities that use the ethtool API.

* Provide a 'cleaned up' ethtool (under some other name) that has:
=C2=A0 - More conventional sub-command syntax, i.e. no '-'/'--' prefix
=C2=A0 - More consistent output formatting

Ben.

--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-9mEvayCk/kgbczWHjqkQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb/69AAoJEOe/yOyVhhEJJWUP+wWgH13wmiptsNnPohErP5EL
8wSbvEowGnx2omXg+nQW9s78ZNuzatiXrw8Y2E9WQPBossS0UGRmfW0emhKKkjvq
rMgr/t9QG2WKkm9eAK5UpRu4rtnwWKFOd6Yvhhv1A2fwKmJd7UX5uYppYcuSREZd
Q4g29iiC0WZNRvFu4L4JWFZcRcxjfqVs1PbskcHZ+33SyrxBohNZmwN5X58TBYN9
bhP8I2EntRD6CpG/DrIk1wmHodzbvYRQmoHnlRrSWsao5crJF51yY29B1fvtPUDJ
i+WTnus4e07/Jp58ovlcL/utMX9WZAE+NTnPxDPx/cy40fURhKpb2Xrb+zjlCZ+d
jtWZ3lu/xEU2ZYRWqHrMpi+MrqrdFQzQ/LKVKjdOsRkWrwfBCrAPNTewQo3YVBTR
kjT0TNjVWBka2YBC+RS+JOqtfeE6HXJyoW40yMhNrlPi5XUGVYc91GvopvvV4KoS
dwz8tZyxjOdF3lzUTttwsdP8zHFJfTyNWtL554/8wEbPqCxAs2tOjRWKdkTb8NDm
Y3IeUFP4uSlZ8zO/3RBV6mkIsOIMpU5V9fzHeNjkgO7sTyHs+/ZIQNHxwTIyuDr2
rDCObTdlo1MI9PkcaeOKFHFx60pbiJX966zxiaBInvWmgfZ+WBC27C9ZCKQ7NUTX
3cySCAnr0NWTaIN075eO
=ZAGy
-----END PGP SIGNATURE-----

--=-9mEvayCk/kgbczWHjqkQ--
