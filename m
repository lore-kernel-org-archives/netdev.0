From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Sat, 12 Apr 2008 01:23:17 +0200
Message-ID: <47FFF2E5.9040807@imap.cc>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net> <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net> <47FEBDAA.7010305@rtr.ca> <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi> <47FF6555.50004@rtr.ca> <20080411143537.GA27874@2ka.mipt.ru> <47FFE33C.1000707@imap.cc> <20080411222536.GA25893@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA7986C66DA18ED8DFC32FB07"
Cc: Mark Lord <lkml@rtr.ca>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, Jeff Garzik <jeff@garzik.org>,
	rjw@sisk.pl, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:45495 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756053AbYDKXXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 19:23:33 -0400
In-Reply-To: <20080411222536.GA25893@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA7986C66DA18ED8DFC32FB07
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Sat, 12 Apr 2008 02:25:36 +0400, Evgeniy Polyakov wrote:
> On Sat, Apr 12, 2008 at 12:16:28AM +0200, Tilman Schmidt (tilman@imap.c=
c) wrote:
>> So I was right after all? Bug reports from people who (for whatever
>> reason, including having to earn their living) cannot do a bisect are
>> not welcome?
>=20
> You got it wrong.

Did I really? Let's see ...

> If bug is subtle and developers can not reproduce it, there are only tw=
o
> ways out of the problem: to help developers or not to help.
>=20
> In the latter case bug report is useless (except that to show that it
> exists, since practically no one can fix it until some new details
> added).

Looks like you're saying I was right after all. Useless bug reports
shouldn't be submitted.

So please answer this simple question: If I know beforehand that I won't
have the time to do a bisect (or other similarly time-consuming task the
maintainers might ask from me), should I report the bug, or should I
keep my knowledge to myself?

This question is not theoretical. It's a situation I find myself in
quite regularly, because I allow myself the luxury of building most rc
kernels and even the odd mm kernel just for fun even though I have a
daytime job and a family to feed. It would be quite easy to look the
other way if I encounter a problem in one of those, hoping someone else
with more time on his or her hands will also come across it and report
it. So far my conscience told me not to do that. But if reporting it
without being able to follow up on it is considered useless then my
conscience was apparently wrong. Just say the word, and I'll stop what
I'm doing. I'll have no problem finding other things to do with my time.

> Bisection was just an example of the help, reporter can provide.

Sure. It's not about bisection specifically, but about the time a
reporter is able to invest in addition to what went into the report
already. But bisection is is a good example, because it's the most
time-consuming of all the tasks routinely asked from bug reporters.

> If you can not proceed with what was suggested, then do
> not piss anyone off because you were told to do something to help.

If a polite "sorry, I don't have the time" already counts as pissing
off, the only choice left is to avoid the situation in which I'd have to
say that. IOW, don't report bugs if I don't have the time to follow
through. Again: if that is what you want, I have no problem with it.

> If you go to the doctor because of aching throat and he asks you to
> open a mouth, you will not blame him for asking you to do that.

That analogy is wrong on so many accounts. It is not my throat that's
aching. A doctor would not insult me for not wanting to open my mouth
but rather ask if there was perhaps a valid reason for that. Not to
mention that opening my mouth takes substantially less time than a Linux
kernel bisection ...

A better analogy would be if I see an object lying on the highway, and I
stop at the next service area to call the police and alert them about
the possible danger. If they'd ask me to drive back to the place where I
saw it in order to describe precisely where it lay and what it looked
like, I think I might indeed become a bit upset.

HTH
T.

PS: I'll shut my big mouth now. The topic has been beaten to death.


--------------enigA7986C66DA18ED8DFC32FB07
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFH//LwQ3+did9BuFsRAkCOAJ0criWknfNgcuWBFsN/4piArg8mzgCeO6zf
kOBtgl8qybMb7Q9L8HfHYIg=
=hquZ
-----END PGP SIGNATURE-----

--------------enigA7986C66DA18ED8DFC32FB07--
