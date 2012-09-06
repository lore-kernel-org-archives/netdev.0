From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/6] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 06 Sep 2012 02:04:20 -0700
Message-ID: <1346922260.4228.20.camel@jtkirshe-mobl>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1346888106-25638-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120906080938.GE2550@netboy.at.omicron.at>
	 <1346921067.4228.12.camel@jtkirshe-mobl>
	 <20120906084954.GH2550@netboy.at.omicron.at>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-f6CXj17wJfOmEtXSA1NK"
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9986 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554Ab2IFJEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 05:04:22 -0400
In-Reply-To: <20120906084954.GH2550@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-f6CXj17wJfOmEtXSA1NK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-09-06 at 10:49 +0200, Richard Cochran wrote:
> On Thu, Sep 06, 2012 at 01:44:27AM -0700, Jeff Kirsher wrote:
> >=20
> > As I recall, he stated he was going to integrate your suggestions in a
> > new patch set that would follow this one.
>=20
> Okay, but won't that mean moving the time stamping functions back, and
> removing the #ifdefs again?

That maybe, I do not know what Matthew has in mind to integrate your
suggestions.

> > Also, IMHO, while I look at pre-processor tags all day and get used to
> > matching up #ifdef to #endif's, I still see #endif /* CONFIG_IGB_PTP */
> > useful.  While it is not currently consistent, I see it more useful to
> > fix as we go, rather than create a single patch to add a comment for
> > every #endif.
>=20
> Okay, fine.
>=20
> Thanks,
> Richard



--=-f6CXj17wJfOmEtXSA1NK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQSGcUAAoJEOVv75VaS+3OyHQQAIHx+gH6H6qoKI27Pgqj+Mcp
9dqaimEWR6zhTPLnzlaeAJ4NalbepkvM3m4MbaCXo2SLuPGAHWkFgIlcVnOmNRpL
IRx6vWtiLko+xQ8+f8g9MCcjrpkC62AYwSngKNneld5XKN9lWpWQVIYbCOVQ648h
0M7lNvl04nKTDDnVzv/IEmwfrklOfZxGm08DRiNPIcGcD6EaMmmN2VS9vDwCVB/H
eOpja0ZQMeyBHYnfoCLcx7MF2AFf7wrL6TMck4W3odMsajkvUhJpuGnBiKKL1E8U
JXmgDBNJlMLbieAdKl6yJXbKcJypNb7P2RXEel+I/YeLRR9ZeFMNhDogZyvJD3nK
aSgsdjdlD7rfGb5QnxejS4HeBrb52k/6bGp6VkeMz28NQju/s7RC7TL1z9e8tQSe
cVW2MggM1/HjDksYaWFdizBPFPlS9/jONTddvaBFcEO4D112uLSx7IUxDOHOwNoG
MIQQzxtU5q5IMoH3E2hwv0K9Zpauk1EcdrFyTrp90VBOAmHO6ePboKJ60AxZTPEN
ZqqDrLVXY6yCy7Enu639hZMvWngzcwB3yeRObpEYdKiYi9rOeHuEqe4ztPhJJ6hE
WVFHevHlytN2dBkY0ktAoawcwiAclxRG9RYeh9St9Q8+9qlGftgEm0b1eDlhdUNy
0eTWe2UdivSNsdtb44g3
=8ZRY
-----END PGP SIGNATURE-----

--=-f6CXj17wJfOmEtXSA1NK--
