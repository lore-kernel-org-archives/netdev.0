From: dag dg <dagofthedofg@gmail.com>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN card
Date: Wed, 1 May 2013 15:24:21 -0500
Message-ID: <CAO2Qn5moQWSHhJPA0B4Cmu5ZXmE=RvNQMu6tTnb_6=sQoBT5vA@mail.gmail.com>
References: <1367431305.12353.8.camel@dcbw.foobar.com> <87r4hqbleh.fsf@nemi.mork.no>
 <1367438620.12353.11.camel@dcbw.foobar.com> <87mwsebghb.fsf@nemi.mork.no>
 <CAO2Qn5m08QOBJfuvR1xAF9msw2WX0mAT64=s8VmXuO41h9dkWg@mail.gmail.com> <1367439868.12353.22.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
	Matthias Urlichs <smurf@smurf.noris.de>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:45511 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756828Ab3EAUYm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 16:24:42 -0400
In-Reply-To: <1367439868.12353.22.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry the mailing list was complaining about my HTML mode. How would I
find the actual novatel E371 device ID? If I get some guidance there
I'd be happy to pull the data.

On Wed, May 1, 2013 at 3:24 PM, Dan Williams <dcbw@redhat.com> wrote:
> On Wed, 2013-05-01 at 15:20 -0500, dag dg wrote:
>> Vendor ID is 413c Product ID is 819b
>
> Bjorn meant the actual Novatel E371 device IDs...
>
> Dan
>
>>
>> On Wed, May 1, 2013 at 3:19 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>>
>> > Dan Williams <dcbw@redhat.com> writes:
>> >
>> > > On Wed, 2013-05-01 at 20:33 +0200, Bj=F8rn Mork wrote:
>> > >> Dan Williams <dcbw@redhat.com> writes:
>> > >>
>> > >> > A rebranded Novatel E371 for AT&T's LTE bands.
>> > >>
>> > >> I don't think we're handling the Novatel branded E371 yet?  I t=
ried
>> > >> googling for ID of that, but were unable to find it.  I guess y=
ou don't
>> > >> know either...  Well, nothing we can do about that until someon=
e reports
>> > >> it.
>> > >
>> > > See the referenced bug report which prompted this:
>> > >
>> > > https://bugzilla.redhat.com/show_bug.cgi?id=3D955426
>> > >
>> > > It's definitely QMI capable.
>> >
>> > Yes, absolutely.
>> >
>> > I just assumed the E371 exists with a Novatel vendor ID as well. W=
hich
>> > we could and should also add, if we only knew what the product ID =
is.
>> >
>> > But it wasn't my intention to question the addition of the Dell
>> > rebranded E371. There's absolutely no need to let that wait. Sorry=
 for
>> > being unclear.  I am not communicating well today...
>> >
>> >
>> >
>> >
>> > Bj=F8rn
>> >
>> >
>
>
