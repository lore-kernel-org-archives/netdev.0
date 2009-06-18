From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless netns work
Date: Thu, 18 Jun 2009 23:48:14 +0200
Message-ID: <1245361694.6495.2.camel@johannes.local>
References: <1245328543.13790.31.camel@johannes.local>
	 <1245329713.13790.37.camel@johannes.local>
	 <40f31dec0906181016nffa031flac8f464c929f1bc9@mail.gmail.com>
	 <43e72e890906181443g54269d1bm7ce24dcb46e7e921@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-3abe21AtgDqps6qiskoI"
Cc: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Georgy Berdyshev <codingmaster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <43e72e890906181443g54269d1bm7ce24dcb46e7e921-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-3abe21AtgDqps6qiskoI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-06-18 at 14:43 -0700, Luis R. Rodriguez wrote:

> For example, I see you used mac80211_hwsim and was able to use two
> wlan interfaces to talk to each other. This seems great for testing
> purposes but it remains unclear to me the advantage of testing with
> separate namespaces vs creating two wlan interfaces on one namespace
> with mac80211_hwsim.

You cannot ping within one namespace and have the packets actually flow
over the virtual 'air'.

johannes

--=-3abe21AtgDqps6qiskoI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOrYaAAoJEODzc/N7+QmaKnMP/jOZMGePN6ZQKvIqaU5BmCb8
KdPVolnOcYE3CX8WifJghf6SLsXVJ/CmaMzm8YHvQSVas4+QnybcxE75Zj6IdQ2B
OL2e/KcEEGMF4cEg21hp48uUe9WRzbHzREZqR1TbIgZB5rQNYCvo5ZMeVDHUcaDZ
EoSP0iOkVWdTS9mS8pOOx4AgxJsWbGBowYhV487JM3TShaWC864CyLsFwbIFOVhr
JUioikdlEAx94uv7CDPGZfJ99nEb1iUlq34Nyu7hSGCZCLN2kwi9tbJAGouGTB3C
hTyFov9hQ+LUwPMO82UH7SATh9aeeF6OYSgpjKYPEuYO/bdhVt1KT9F7SpsAb5Q/
wTPGbxlOwDhegZ/abgZBrRPyidSNIeobgdZLZkynwrDgb3RzK95qetdyCuLQCNRK
Z/PlOeTREjJDr2ZgZwcd0APFWZee/eZflePdSJ2yMeVkhDPn6enUgp+gxdr29ZZl
E5wRs6CrchlFezJtPQuvaMHcLXZEx9GDRJNHOGCxNKQjNrN5x0+bfetGnmb2EP++
3irdfegmZq5Mj911M7r0UZ1ghNSo1SwtM51R2yE9g1zkpRDn77FZmWs+qOcQnSZa
n7ETVaCj1m0QaDuSu4ODqaIp6VkwjM5q8ZYiFYLBOAnVw/4K295/+RQMj1O8RsW8
5hJbKpWe/0/IorFEvdjB
=udJN
-----END PGP SIGNATURE-----

--=-3abe21AtgDqps6qiskoI--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
