From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN
 card
Date: Wed, 01 May 2013 15:24:28 -0500
Message-ID: <1367439868.12353.22.camel@dcbw.foobar.com>
References: <1367431305.12353.8.camel@dcbw.foobar.com>
	 <87r4hqbleh.fsf@nemi.mork.no> <1367438620.12353.11.camel@dcbw.foobar.com>
	 <87mwsebghb.fsf@nemi.mork.no>
	 <CAO2Qn5m08QOBJfuvR1xAF9msw2WX0mAT64=s8VmXuO41h9dkWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
	Matthias Urlichs <smurf@smurf.noris.de>
To: dag dg <dagofthedofg@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAO2Qn5m08QOBJfuvR1xAF9msw2WX0mAT64=s8VmXuO41h9dkWg@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-01 at 15:20 -0500, dag dg wrote:
> Vendor ID is 413c Product ID is 819b

Bjorn meant the actual Novatel E371 device IDs...

Dan

>=20
> On Wed, May 1, 2013 at 3:19 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
>=20
> > Dan Williams <dcbw@redhat.com> writes:
> >
> > > On Wed, 2013-05-01 at 20:33 +0200, Bj=C3=B8rn Mork wrote:
> > >> Dan Williams <dcbw@redhat.com> writes:
> > >>
> > >> > A rebranded Novatel E371 for AT&T's LTE bands.
> > >>
> > >> I don't think we're handling the Novatel branded E371 yet?  I tr=
ied
> > >> googling for ID of that, but were unable to find it.  I guess yo=
u don't
> > >> know either...  Well, nothing we can do about that until someone=
 reports
> > >> it.
> > >
> > > See the referenced bug report which prompted this:
> > >
> > > https://bugzilla.redhat.com/show_bug.cgi?id=3D955426
> > >
> > > It's definitely QMI capable.
> >
> > Yes, absolutely.
> >
> > I just assumed the E371 exists with a Novatel vendor ID as well. Wh=
ich
> > we could and should also add, if we only knew what the product ID i=
s.
> >
> > But it wasn't my intention to question the addition of the Dell
> > rebranded E371. There's absolutely no need to let that wait. Sorry =
for
> > being unclear.  I am not communicating well today...
> >
> >
> >
> >
> > Bj=C3=B8rn
> >
> >
