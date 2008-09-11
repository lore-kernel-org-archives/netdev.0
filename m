From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: ipv6 neighbour code keeps interfaces held
Date: Thu, 11 Sep 2008 18:12:38 +0200
Message-ID: <1221149559.6986.30.camel@johannes.berg>
References: <1221081539.3804.33.camel@johannes.berg>
	 <20080910.164009.92497081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-MpwxJTPizpWbtvh7mViM"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:53264 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbYIKQNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 12:13:14 -0400
In-Reply-To: <20080910.164009.92497081.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MpwxJTPizpWbtvh7mViM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-09-10 at 16:40 -0700, David Miller wrote:

> Here is a quick patch that might resolve this specific situation.
> Let me know how it works for you:

I haven't seen it again so far, but it's not necessarily an indication
that it worked. But normally I think I probably would have seen it
already by now.

johannes

--=-MpwxJTPizpWbtvh7mViM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIyUNxAAoJEKVg1VMiehFYXwMQAKco6TuiCBOzQVKLzfimauo5
u+jXZNxiKCPpo7QYQTQsMvVleoa8DvZmCL5EgOgb6YLkdMZp9VlIH4r9hxoMtryq
p4Y4FMheVs19y4XeH6LS2A0ksuWvYxG9p6k9cP11vW9HfKwfSRq/ExKjshoyrWv1
0lzlww4qwPbn584k3RNiUELW1Vu2weffROqJQSLiMI96CmYh+rnPzMBzmz1MyxoL
EV5Y/HG+z8iZTzXGNMEaAthVZ+mplmWO/6YOrpaOdz6GCQMckF/+P7IkqadNkJ6n
8TyIxgmBJfxsOf5yG3AqIx1VJQoesgj2/VYSBEiZWYfkLoVo/2q1dw9wKEwTYp40
EXLVn/pKDa4pDR5xrGYc0l8p/1AsM76UsNf+rFdv+DlzCn1rPx3hxdPbbpSmI65z
z/L0EJfdaJPr39Vezjn+EUTPWDyHebZO2rdhMduxHHYGGdUfiX8jIF7ZyHkP9J58
E2rBmP9KJHA2YAStp+dEXh9uMvHwTaDR8n72tw2zsdvrql41M4xt0Osyj2JDhtBQ
Iprs/ziRecVkUiZe20ql5EpFUzcK3WYPOwEEVoEC6GH2YBalAKHV8iZJwq8HWdtf
gW+ry1oYN8H3xrhCfYM/YhTJNIBgBPK/RfIG8YdXsk4IWSS/o0sOUgCp9WXauyz0
odjxYVIfZN71cPg9iFt9
=KBsF
-----END PGP SIGNATURE-----

--=-MpwxJTPizpWbtvh7mViM--

