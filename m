From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: MPLS for Linux kernel
Date: Mon, 21 Nov 2011 09:17:11 -0800
Message-ID: <20111121091711.1be69369@nehalam.linuxnetplumber.net>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com>
	<4ECA67C6.2080802@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs,
	Linux Network Development list <netdev@vger.kernel.org>
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58329 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756078Ab1KURRS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 12:17:18 -0500
In-Reply-To: <4ECA67C6.2080802@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Nov 2011 16:01:26 +0100
"Jorge Boncompte [DTI2]" <jorge@dti2.net> wrote:

> El 20/11/2011 22:59, Igor Maravi=C4=87 escribi=C3=B3:
> > Hi all,
> > I've been working on implementation of MPLS for Linux kernel, for a
> > some time now.
> > I continued the work of James Leu
> > (https://sourceforge.net/projects/mpls-linux/) and used some fixes =
of
> > Jorge Boncompte
> > (http://mpls-linux.git.sourceforge.net/git/gitweb.cgi?p=3Dmpls-linu=
x/net-next;a=3Dshortlog;h=3Drefs/heads/net-next-mpls).
> >=20
> > I fixed a lot of bugs, so now it can be compiled and run with all
> > Kernel Hacking options enabled.
> > My code could be found on this sites:
> >=20
> > https://github.com/i-maravic/MPLS-Linux
> > https://github.com/i-maravic/iproute2
> >=20
> > Any feedback is appreciated :)
>=20
> 	Provide, clean, separated, and commented changes to the upstream pro=
ject as we
> have asked you several times to do.
>=20
> 	mpls-linux it is not ready to go upstream in my opinion.

Out of tree is out of mind. Very few developers will bother with
a kernel component not in the mainline tree.

Staging?
