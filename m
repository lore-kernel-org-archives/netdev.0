From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN
 card
Date: Wed, 01 May 2013 15:28:47 -0500
Message-ID: <1367440127.12353.23.camel@dcbw.foobar.com>
References: <1367431305.12353.8.camel@dcbw.foobar.com>
	 <87r4hqbleh.fsf@nemi.mork.no> <1367438620.12353.11.camel@dcbw.foobar.com>
	 <87mwsebghb.fsf@nemi.mork.no>
	 <CAO2Qn5m08QOBJfuvR1xAF9msw2WX0mAT64=s8VmXuO41h9dkWg@mail.gmail.com>
	 <1367439868.12353.22.camel@dcbw.foobar.com>
	 <CAO2Qn5moQWSHhJPA0B4Cmu5ZXmE=RvNQMu6tTnb_6=sQoBT5vA@mail.gmail.com>
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
In-Reply-To: <CAO2Qn5moQWSHhJPA0B4Cmu5ZXmE=RvNQMu6tTnb_6=sQoBT5vA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-01 at 15:24 -0500, dag dg wrote:
> Sorry the mailing list was complaining about my HTML mode. How would =
I
> find the actual novatel E371 device ID? If I get some guidance there
> I'd be happy to pull the data.

Don't worry about it, Bjorn was just saying he wished we had that ID.
You don't need to go looking for it if you don't want to.

Dan

> On Wed, May 1, 2013 at 3:24 PM, Dan Williams <dcbw@redhat.com> wrote:
> > On Wed, 2013-05-01 at 15:20 -0500, dag dg wrote:
> >> Vendor ID is 413c Product ID is 819b
> >
> > Bjorn meant the actual Novatel E371 device IDs...
> >
> > Dan
> >
> >>
> >> On Wed, May 1, 2013 at 3:19 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wr=
ote:
> >>
> >> > Dan Williams <dcbw@redhat.com> writes:
> >> >
> >> > > On Wed, 2013-05-01 at 20:33 +0200, Bj=C3=B8rn Mork wrote:
> >> > >> Dan Williams <dcbw@redhat.com> writes:
> >> > >>
> >> > >> > A rebranded Novatel E371 for AT&T's LTE bands.
> >> > >>
> >> > >> I don't think we're handling the Novatel branded E371 yet?  I=
 tried
> >> > >> googling for ID of that, but were unable to find it.  I guess=
 you don't
> >> > >> know either...  Well, nothing we can do about that until some=
one reports
> >> > >> it.
> >> > >
> >> > > See the referenced bug report which prompted this:
> >> > >
> >> > > https://bugzilla.redhat.com/show_bug.cgi?id=3D955426
> >> > >
> >> > > It's definitely QMI capable.
> >> >
> >> > Yes, absolutely.
> >> >
> >> > I just assumed the E371 exists with a Novatel vendor ID as well.=
 Which
> >> > we could and should also add, if we only knew what the product I=
D is.
> >> >
> >> > But it wasn't my intention to question the addition of the Dell
> >> > rebranded E371. There's absolutely no need to let that wait. Sor=
ry for
> >> > being unclear.  I am not communicating well today...
> >> >
> >> >
> >> >
> >> >
> >> > Bj=C3=B8rn
> >> >
> >> >
> >
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
