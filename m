From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN card
Date: Wed, 01 May 2013 22:19:28 +0200
Message-ID: <87mwsebghb.fsf@nemi.mork.no>
References: <1367431305.12353.8.camel@dcbw.foobar.com>
	<87r4hqbleh.fsf@nemi.mork.no>
	<1367438620.12353.11.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
	Matthias Urlichs <smurf@smurf.noris.de>, dagofthedofg@gmail.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1367438620.12353.11.camel@dcbw.foobar.com> (Dan Williams's
	message of "Wed, 01 May 2013 15:03:40 -0500")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw@redhat.com> writes:

> On Wed, 2013-05-01 at 20:33 +0200, Bj=C3=B8rn Mork wrote:
>> Dan Williams <dcbw@redhat.com> writes:
>>=20
>> > A rebranded Novatel E371 for AT&T's LTE bands.
>>=20
>> I don't think we're handling the Novatel branded E371 yet?  I tried
>> googling for ID of that, but were unable to find it.  I guess you do=
n't
>> know either...  Well, nothing we can do about that until someone rep=
orts
>> it.
>
> See the referenced bug report which prompted this:
>
> https://bugzilla.redhat.com/show_bug.cgi?id=3D955426
>
> It's definitely QMI capable.

Yes, absolutely.

I just assumed the E371 exists with a Novatel vendor ID as well. Which
we could and should also add, if we only knew what the product ID is.

But it wasn't my intention to question the addition of the Dell
rebranded E371. There's absolutely no need to let that wait. Sorry for
being unclear.  I am not communicating well today...




Bj=C3=B8rn
