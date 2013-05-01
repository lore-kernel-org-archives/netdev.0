From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN
 card
Date: Wed, 01 May 2013 15:04:03 -0500
Message-ID: <1367438643.12353.12.camel@dcbw.foobar.com>
References: <1367431305.12353.8.camel@dcbw.foobar.com>
	 <87r4hqbleh.fsf@nemi.mork.no>
	 <20130501.144241.1818296448373016452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, stable@vger.kernel.org,
	smurf@smurf.noris.de, dagofthedofg@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755916Ab3EAUBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 16:01:53 -0400
In-Reply-To: <20130501.144241.1818296448373016452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 14:42 -0400, David Miller wrote:
> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Wed, 01 May 2013 20:33:10 +0200
>=20
> > Dan Williams <dcbw@redhat.com> writes:
> >=20
> >> A rebranded Novatel E371 for AT&T's LTE bands.
> >=20
> > I don't think we're handling the Novatel branded E371 yet?  I tried
> > googling for ID of that, but were unable to find it.  I guess you d=
on't
> > know either...  Well, nothing we can do about that until someone re=
ports
> > it.
> >=20
> > For the qmi_wwan part:
> > Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> >=20
> >=20
> >> diff --git a/drivers/usb/serial/option.c b/drivers/usb/serial/opti=
on.c
> >> index 558adfc..569caf6 100644
> >> --- a/drivers/usb/serial/option.c
> >> +++ b/drivers/usb/serial/option.c
> >=20
> > Combining net and usb patches in the same commit is probably not wi=
se?
>=20
> Yes, this causes problems, please re-submit the networking portion al=
l
> by itself.

Will do.

Dan
