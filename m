From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Patch net] igb: fix a typo in igb_reset_q_vector()
Date: Wed, 22 Apr 2015 00:16:52 -0700
Message-ID: <1429687012.2638.216.camel@jtkirshe-mobl>
References: <1429658433-8634-1-git-send-email-xiyou.wangcong@gmail.com>
	 <5536EAA3.10701@lab.ntt.co.jp> <1429662577.2638.201.camel@jtkirshe-mobl>
	 <CAM_iQpWjUiJdb5E8QHvquzweQsEEdDQqtxJLyBL8KM1zOL6W9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6KKqV3HCNPfRWdUG9bfO"
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60419 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757933AbbDVHQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2015 03:16:54 -0400
In-Reply-To: <CAM_iQpWjUiJdb5E8QHvquzweQsEEdDQqtxJLyBL8KM1zOL6W9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6KKqV3HCNPfRWdUG9bfO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-04-21 at 21:35 -0700, Cong Wang wrote:
> On Tue, Apr 21, 2015 at 5:29 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > On Wed, 2015-04-22 at 09:26 +0900, Toshiaki Makita wrote:
> >> Hi Cong Wang,
> >>
> >> I have already sent a patch to intel's tree.
> >> http://git.kernel.org/cgit/linux/kernel/git/jkirsher/net-queue.git/com=
mit/?h=3Ddev-queue&id=3D02ac4b65689f8df824117395fd8d160c04161a7b
> >>
>=20
> I didn't know this tree, I use -net tree.

Guess that is why we have a MAINTAINERS file AND get_maintainer.pl
script. :-)

> >>
> >
> > Oops, yeah.  I already have this in my queue.  I wondered why the patch
> > seemed familiar, Cong dropping your patch since I already have
> > Tochiaki's patch in my queue.
>=20
> Sure. Please queue it for -stable too, since it apparently fixes a bug.

Will do.



--=-6KKqV3HCNPfRWdUG9bfO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVN0rkAAoJEOVv75VaS+3OzvkP/RI24+W+j4u6WlN9SjOQJoEa
E22zraztBFBWS83NPVf9Jmo/zLyQFiF/H7ad2vUiteqwKNeXyvPKY+XlPYJSdrAS
9i2RkkTKzQ93tApXmqSfeZn5u9TW8qBXGyKZrFL/CiwrVPw/LTNMzhNDX3KPubEu
ks7pidJelRZWxGqJSvydS8PgGiFHCzkR3I49VoJrT+JFlpxTXxDpcZVCQvk/jEf2
bOzcES5nL0u57nwTg7P5r1Q0EwFy9IG+aTn5ebFv1D4z+qrVdNIbr8swow2at2Qf
RaZZJpie5uzfBCRUg2gGyV4K4Ke7f/Rm22gmqDCxpcOsBhSisnkUcv5vVPooVQqo
nxHoxTeLVFUe+/g8v/aMDWSYOAfdRLeJ4xk+onwuSY+uqjYHTy6a2+EiAXm/GA46
KGeLX1iJQkKWNPfOGXG8mj81PX9OmqHW/SQmtv6gvH5ZmUzPz6l2deSnTNvkXnbJ
3MA/LxsEF3f/N2V5MzZflkjR/5ZlkLPpBn/jqyrd3+BgW/jobOfXDdaPmNzunS6k
BlUpCJELdZRv/L+mdJZqMkeSOCO4PZh6rq9NDJAlcQXujpVEiR77iDM0pYHuC6OB
gARICUqPHZ+K+4UKM99ENTlhp9cFvWqKRRbAfUzOCJmn/Jr4pmeZ7DTbfiYtfbBI
WXpg/cuynnk2j9oKU0TU
=3u5D
-----END PGP SIGNATURE-----

--=-6KKqV3HCNPfRWdUG9bfO--
