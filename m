From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: [BUG] stacktrace from skb_checksum_help() and skb_gso_segment()
Date: Wed, 26 Jul 2006 09:00:39 +0200
Message-ID: <200607260900.46599.eike-kernel@sf-tec.de>
References: <200607260841.54017.eike-kernel@sf-tec.de> <20060726064419.GB32190@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2519558.hmFPTIC7WH";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:62435 "EHLO mail.sf-mail.de")
	by vger.kernel.org with ESMTP id S1030415AbWGZG6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 02:58:54 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060726064419.GB32190@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2519558.hmFPTIC7WH
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Am Mittwoch, 26. Juli 2006 08:44 schrieb Evgeniy Polyakov:
> On Wed, Jul 26, 2006 at 08:41:48AM +0200, Rolf Eike Beer=20
(eike-kernel@sf-tec.de) wrote:
> > linux-2.6 git tree from yesterday.
> >
> > Before this the sky2 network driver was working. After a pseudo hotplug
> > of the device it was working again (at least if you receive this mail
> > *g*).
> >
> > What next?
>
> It is not a bug, but remind to update NAT helper function.
> It has nothing with device drivers and is only printed once.

But why was my sky2 down afterwards? There's nothing in the log but this.

Eike

--nextPart2519558.hmFPTIC7WH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExxMeXKSJPmm5/E4RAgRQAJ9EcV/8yD+xeAGm6X7AddbBq2Af9ACeLhF8
DYaLNyVMlXAgDLmscP3/Jgs=
=PEsa
-----END PGP SIGNATURE-----

--nextPart2519558.hmFPTIC7WH--
