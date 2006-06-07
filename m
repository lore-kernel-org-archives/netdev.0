From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 18:06:40 +0200
Message-ID: <1149696400.3925.13.camel@johannes>
References: <4485D66B.7080108@lwfinger.net>
	 <1149682213.3999.14.camel@johannes>  <4486F513.5050906@lwfinger.net>
	 <1149695470.3925.7.camel@johannes>  <4486F866.9040901@errno.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GrPFZfhbYdDntfIdaB7m"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59286 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932281AbWFGQGp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 12:06:45 -0400
To: Sam Leffler <sam@errno.com>
In-Reply-To: <4486F866.9040901@errno.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GrPFZfhbYdDntfIdaB7m
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-06-07 at 09:01 -0700, Sam Leffler wrote:

> Beware of the order of IE's in the management frames; some AP's are
> touchy about this.

Uh oh. I have no idea where the ieee80211 layer sticks that one,
probably at the end.

johannes

--=-GrPFZfhbYdDntfIdaB7m
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARIb5jqVg1VMiehFYAQJ3eBAAiyZX4M8P/4NprtitHRlWe35oNGWPrQy/
m8KXQbufjuUaHq3k1kyrs1wxPg2wbhXDIIqVgdjaAXw5pDpciHJ96XscAx1XuH0w
DkmAW6+zHhXEgtshjfsM/1m7EzZZOtDddTKx5AHg5iZO1F1c8TUnL5B6u8oWUR4F
Gw8SnLpbNso1hpK5l/7vTYrCDLRTHJKAgJwFOC0tjeCt0DA8XHl6OOkq73srKz8e
6DoSisVVsFzBNlDLxCWCnfMIwo79qrZD5uQ5bl4J2hzuYFdIcE6BZawrXjuAzPvB
lvOI0Y9v/qBt9pnnvS5S/BZXcdWH+kjOVV/Vw1Wo0WqBtjAxG16Jbb3xjwYJ5mr5
/zP0fg1xFau0LaicvSmB9Uwr1+ImqjWPOAtYNTqSiFe6kp7/caayEUKSO4LZ0ANW
mu40LpT6bBGshsXNBkdEByJofRTcfyaMIuLwchR0vlfEx26OGc3zDcxsRHp//WLY
iJAgWQ7eOaB/xJIj/6C5Bzven4wT9SFAZaK044K9ug8TQvxXEsMdPMVCxtLBX/V+
Zh0jjhAVuUiKdvE2HAupsmqOjn0z9NTS91Qe08+VK7T6gbMPfzXKnnN9vQvCWwxQ
wqhNuSfUfXJ+nl0DGdu7lwBNN9SpiVy/fZ3VF9wHxoclzo60Nytun/Shlj2rr2im
nl0+nucO9RI=
=O7aJ
-----END PGP SIGNATURE-----

--=-GrPFZfhbYdDntfIdaB7m--

