From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [GIT] Networking
Date: Tue, 8 Sep 2015 16:51:01 +0000
Message-ID: <599B264F-0076-4C80-9EF9-853D32D09E3F@intel.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
 <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
 <20150903.104032.767889134756094076.davem@davemloft.net>
 <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
 <CA+55aFzZe2buU-LxAktxYNojuvMbUNt64QiKDpGsfFwtrbf+Qg@mail.gmail.com>
 <62408D76-2E53-4914-97A9-32B65B167F9B@holtmann.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB8D542@AcuExch.aculab.com>
 <8BC0F5D8-5872-4387-BACA-BE7EAF479928@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB8E788@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_1A66D369-FE59-4431-80F9-3C1078D07BBA";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62479 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755015AbbIHQvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2015 12:51:05 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB8E788@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_1A66D369-FE59-4431-80F9-3C1078D07BBA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On Sep 7, 2015, at 4:02 AM, David Laight <David.Laight@ACULAB.COM> =
wrote:
>=20
> Feed:
> int bar(int (*f)[10]) { return sizeof *f; }
> into cc -O2 -S and look at the generated code - returns 40 not 4.

Yes, indeed it does. And with clang too. I guess I was too easily =
discouraged when looking for a workable syntax some years ago. At the =
time I stopped when the typedef worked, which really just encapsulates =
this. I should have recognized that then. Thanks for making it all so =
clear.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_1A66D369-FE59-4431-80F9-3C1078D07BBA
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV7xH1AAoJEDwO/+eO4+5upvEQAK4JgqEM8q7WoZLtyNpbvgSg
GtqL9mX4kyU/Tzsn3rls8sq80ndWt8UkrCJtbdXdNWikpi3c9I4hbd7cTRTzve+F
J5QNcwxFWq378Pu5+qXi4ldWeLWmVLHuKcozXvL34GnbBS/hnq8quO4ITaDJEvny
xXf6T6KU8XT97WkGXzHHWhDTWEe7WlZz/GCIQoVfQUxbPTPqmCvLdaoQK7pxaD6S
iexIKhg8v+xYsXoQgOkKbBYQqMn1ylwmQ1P/lWSSQ9CdL/G0XNRDA+mO5IX4/ntt
MfezwZhDkjP1lvaQb+Ru9IaBUTnOHO2pO7pmo18HF5weQ/lJnfRKQ4m94hyLiEaU
R6LZMtS/spwofZpdTqtAtU7JCqmRrRArNOPE3w3g7L7BcOWfywdnJBY6Bttt3XFE
PlH9mhjf9C/IrvZr8tJuQdXZwNdkInp0IcUlAiczCMT1BZn0hz7rgIhimPq3q8rG
FD0W+QD2Z2RQ6ZG9qPMBAkdmfhrL0dcxeWbtUPRigSqVAfVCvHH0c2wvaO3tRmz0
rbpBmFFhqK73DymayfW/wZJMaNQ1LHAbweV9eTvmfqBHazjtZbgou14jqut9/6Q5
/6oL2BAQcl/Ems+F8OyzaRjFSdI7CzM6YWMqyQMJdoVrxqCTwDEpu8SVSL1959lA
Ik/368mp4BtngAxZoMM1
=ulYt
-----END PGP SIGNATURE-----

--Apple-Mail=_1A66D369-FE59-4431-80F9-3C1078D07BBA--
