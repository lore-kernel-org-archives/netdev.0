From: "Eggert, Lars" <lars@netapp.com>
Subject: Re: [next PATCH 0/5] net: tcp: DCTCP congestion control algorithm
Date: Tue, 13 May 2014 09:40:19 +0000
Message-ID: <9B2F6EEB-BD3D-4216-8481-13BAF0D29B9C@netapp.com>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
 <CAHA+R7O7yGaMJ+e=nrTmvt+wK7h0kF9okZPTzGseJZa1PiJg9Q@mail.gmail.com>
 <20140512214515.7eb085af@nehalam.linuxnetplumber.net>
 <CAPh34mf-nRwyA0LmSwJXy_e4yqMxZ2BEJFz+3LTW_Po91fY5fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_C5A0EA22-38B3-4730-A0C5-3635BF51482D";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	"sbens@microsoft.com" <sbens@microsoft.com>,
	"Dave Thaler" <dthaler@microsoft.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.netapp.com ([216.240.18.77]:8364 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932650AbaEMJkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 05:40:21 -0400
In-Reply-To: <CAPh34mf-nRwyA0LmSwJXy_e4yqMxZ2BEJFz+3LTW_Po91fY5fw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_C5A0EA22-38B3-4730-A0C5-3635BF51482D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hi,

On 2014-5-13, at 11:34, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> Some IETF background: IETF Meeting 79 (Beijing) Microsoft employees
> presented DCTCP with the intention to standardize DCTCP. The rough
> consensus was the DCTCP is datacenter specific, thus closed door
> technique and in the result not of broader interest for TCPM working
> group. Further effort slowed down quickly.
>=20
> Last IETF meeting in London (IETF 89) Lars Eggert (cc'ed him) picked
> up DCTCP again. My impression was that the willing to adopt or work on
> DCTCP was limited (the way I see it) but not definitely buried.

I presented for Stephen Bensley from Microsoft (CC'ed), who is the main =
driver of the IETF spec. (My contribution was mostly having an intern do =
a FreeBSD implementation, which is being reviewed for inclusion over =
there.)

While the TCPM working group may or may not decide to take this spec on =
as a work item, there is also a newly starting "datacenter latency =
control (DCLC)" research group on the IRTF side that may give this a =
home if TCPM takes a pass. (Mailing list =
https://www.irtf.org/mailman/listinfo/dclc; wiki =
http://wiki.tools.ietf.org/group/irtf/trac/wiki/dclc)

Lars

> The IPR statement licence it under Royalty-Free, Reasonable and
> Non-Discriminatory licence.
>=20
> Hagen


--Apple-Mail=_C5A0EA22-38B3-4730-A0C5-3635BF51482D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQCVAwUBU3HogNZcnpRveo1xAQI2HgP9H4abRtwbPpzpgY5yHdulkwuiQVTIEC0q
0TAGJjlokPSkCHFDQYZAcOezD6PPhxX4j2S4evUNZfRzkstQp4zotUjyRrMqMZj1
kyd+npmL3VxrJ8Y9SKcjiY6wyJjPKFyZpRYzAuowAPke4ewNDXNJnYBFG6iHKxBu
fUrHuVXiw50=
=93Ga
-----END PGP SIGNATURE-----

--Apple-Mail=_C5A0EA22-38B3-4730-A0C5-3635BF51482D--
