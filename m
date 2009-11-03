From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project tree
Date: Wed, 4 Nov 2009 00:09:02 +0100
Message-ID: <14add3d10911031509l328e7674kb625b70250ff30fb@mail.gmail.com>
References: <200911031951.05235.bzolnier@gmail.com>
	 <200911032244.11946.bzolnier@gmail.com>
	 <200911032301.32907.IvDoorn@gmail.com>
	 <200911032334.40547.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivo van Doorn <ivdoorn@gmail.com>, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Randy Dunlap <rdunlap@xenotime.net>,
	Luis Correia <luis.f.correia@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ingo Molnar <mingo@elte.hu>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751818AbZKCXJA@vger.kernel.org>
In-Reply-To: <200911032334.40547.bzolnier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 3, 2009 at 11:34 PM, Bartlomiej Zolnierkiewicz
<bzolnier@gmail.com> wrote:
> On Tuesday 03 November 2009 23:01:32 Ivo van Doorn wrote:
>> > > > The following patch series (against wireless-next) addresses i=
ssues raised
>> > > > during code review and subsequently rejected by rt2x00/wireles=
s/networking
>> > > > maintainers.
>> > >
>> > > Really stop reading only the half of emails, try reading it enti=
rely (or at least don't
>> > > stop at the second word in a sentence). It really starts the bug=
 me to repeat
>> > > myself over and over again because you refuse to read.
>> > >
>> > > Your comments during code review were ACCEPTED with the only rem=
ark that
>> > > it shouldn't be done right here and now.
>> >
>> > Please stop this bullshit. =A0We have some standards for the upstr=
eam code
>> > and by being maintainer you have to live up to this standards and =
make sure
>> > that they are respected instead of watering them down yourself..
>> >
>> > You were not interested even in fixing the headers duplication (it=
 turned
>> > out debugging scripts needed only 25 lines of code to be able to w=
ork with
>> > fixed headers -- 25 LOC in bash scripts used only for debugging in=
stead
>> > of 1800 LOC of kernel code).
>>
>> Yeah I know that. But like I said, I still needed to get around to d=
o that,
>> and I am very happy you were interested in fixing it.
>
> Lets make one thing clear: YOU SHOULD BE THE ONE FIXING IT.
>
> I'm not in slightest interested in wasting my time on such
> things and educating some maintainers about basics.
>
> [ Code duplication is bad, mmm'okay? =A0Just say no, mmm'okay? ]
>

Bart,

Are you really interested in working with us (the rt2x00 project) in
getting the rt2800{pci,usb}
drivers in a better shape, or do you just want to continue your
ramblings on how bad you
think the rt2x00 maintainers, wireless maintainer, and networking
maintainer are in your view?

Just continuing these discussions doesn't help a bit as Ivo, John, and
David said they disagreed
with you on this topic.

If you just want to continue with a hostile take-over of the rt2800
maintainership, then please
let us know that, so that we stop spending time on useless
discussions, and let John Linville
decide how he wants to handle this situation. It would be a shame of
the good patches and work
you did, but if that's the case, than that's it.

Otherwise, please focus on the technical contents of the patches and
work with us to get
these drivers in a better shape.

---
Gertjan.


,
