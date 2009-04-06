From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH 0/4] CDC Phonet function fixes
Date: Mon, 6 Apr 2009 22:12:54 +0300
Message-ID: <200904062212.54620.remi@remlab.net>
References: <200904061758.58057.remi.denis-courmont@nokia.com> <200904061153.46622.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:51160 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbZDFTNO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 15:13:14 -0400
In-Reply-To: <200904061153.46622.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

(My corporate alter ego now on vacation)

Le lundi 6 avril 2009 21:53:46 David Brownell, vous avez =E9crit=A0:
> On Monday 06 April 2009, R=E9mi Denis-Courmont wrote:
> > Here are a bunch of fixes for the Phonet USB gadget function networ=
k
> > interface driver. Comments welcome.
>
> I seem to have missed any patch for this "Phonet" code,
> and so I have no way to evaluate bug fixes to it.  It's
> not in any standard USB patch queue.

Those are there:=20
http://kerneltrap.org/index.php?q=3Dmailarchive/linux-netdev/2008/12/17=
/4438934/thread

AFAIK, they are already in the mainline, though the code is not used by=
 any=20
published gadget driver that I am aware of (paraphrase for "dead [code]=
").

> Got a URL for those patches?  Maybe you should just
> submit the drivers/usb/gadget/f_phonet.c code, and
> something using it, with these patches pre-merged...

It seems I've been overly stingy on the Cc:s in December. I would rathe=
r=20
not -on top of that- bother davem/gregkh/whoever with a merge conflict =
just=20
for the sake of The Process or cosmetics.

Sorry for the inconvenience.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
