From: Felipe Balbi <balbi@ti.com>
Subject: Re: SYSFS "errors"
Date: Mon, 18 Feb 2013 22:05:42 +0200
Message-ID: <20130218200542.GB20137@arwen.pp.htv.fi>
References: <20130218153316.GA2663@arwen.pp.htv.fi>
 <20130218155012.GA30974@kroah.com>
 <20130218155215.GB2663@arwen.pp.htv.fi>
 <20130218171334.GA31329@kroah.com>
 <20130218172700.GH2663@arwen.pp.htv.fi>
 <20130218174916.GA2070@kroah.com>
 <20130218184633.GC10755@arwen.pp.htv.fi>
 <20130218164638.7cb53baa@redhat.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JYK4vJDZwFMowpUq"
Cc: <balbi@ti.com>, Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
To: Mauro Carvalho Chehab <mchehab@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130218164638.7cb53baa@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--JYK4vJDZwFMowpUq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Feb 18, 2013 at 04:46:38PM -0300, Mauro Carvalho Chehab wrote:
> > > > No such device - /sys/devices/system/edac/mc/mc0/sdram_scrub_rate
> > >=20
> > > Odd, go ask the edac developers
> >=20
> > will do ;-)
>=20
> Well, the question is missing ;) /me assumes that you want to talk about
> suspending/resume and EDAC, right?

oops, my bad. The thing is that file has read permission but reading it
isn't allowed ;-)

--=20
balbi

--JYK4vJDZwFMowpUq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRIomWAAoJEIaOsuA1yqREPqMQAIcJwkhZsILJMk/f68kb+jYW
ddS0ChYFT2YzFD+f9n2cvM/KGViNwcN5uvBlsQdmYrPT9tt2HXTNahyZ/kr0IW+N
jP5TCEEUf/BcarJDoZQmXh4QbrHyqggNyn4GYyNDGvun7kzsju8DIsJAAPPPMPi3
15jI8YSXBPyfMAOiVtn6FALcFKzf/IbM93qqASwR5acHftxe+5DNs0scwvfEioZN
/Ju865Mqcaggw6/D8FU1W0ZuMWrFwUlIcvWt4PQR2+RTyDyyceGGhIJ5rzpH8hTv
B8Y+pOELH2hdaqLifRE2kbusB2uH/pu0epmS1d6Ej6ilPiqxAP7/GhSPethEdQsG
8/tfLdgG58hmSIQHGvDv8BSmIAQVUCCJsevIPqcuIUw5YlzFmCVFKmyhvGq3NGNT
SXc3DinwxngBx9WXZWeaIgdfZGJ6Uus8HjpNBWm/BDRidL2G4AdBH4h1gKRmUpWD
iD7cLl1CEhGDzlnPx9QcRssOCNhPdjG/wKJ45ojpIbXSFcl7sZIeKQ7cUkJsstah
fa3VUialnJJzHHC+3dF0ZQ8Vx+om8eZ4KH1164GlTI87bxvLLhnYcIYNmOtEx10s
jXDBUiu3CjXT/+L9q2+QtHG9O8mXC9T1+6QgYxIQFNWIxIGpf+C6syBljiDyGa1i
ta6Hfne1GOm9gb8vzpse
=1AVI
-----END PGP SIGNATURE-----

--JYK4vJDZwFMowpUq--
