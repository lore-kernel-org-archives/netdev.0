From: dag dg <dagofthedofg@gmail.com>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN card
Date: Wed, 1 May 2013 15:22:58 -0500
Message-ID: <CAO2Qn5n5qWdybCt403s8WRL+XgJn9u0rPfAp+wsEyui43LVPoQ@mail.gmail.com>
References: <1367431305.12353.8.camel@dcbw.foobar.com> <87r4hqbleh.fsf@nemi.mork.no>
 <1367438620.12353.11.camel@dcbw.foobar.com> <87mwsebghb.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
	Matthias Urlichs <smurf@smurf.noris.de>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87mwsebghb.fsf@nemi.mork.no>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vendor ID is 413c Product ID is 819b

On Wed, May 1, 2013 at 3:19 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Dan Williams <dcbw@redhat.com> writes:
>
>> On Wed, 2013-05-01 at 20:33 +0200, Bj=F8rn Mork wrote:
>>> Dan Williams <dcbw@redhat.com> writes:
>>>
>>> > A rebranded Novatel E371 for AT&T's LTE bands.
>>>
>>> I don't think we're handling the Novatel branded E371 yet?  I tried
>>> googling for ID of that, but were unable to find it.  I guess you d=
on't
>>> know either...  Well, nothing we can do about that until someone re=
ports
>>> it.
>>
>> See the referenced bug report which prompted this:
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=3D955426
>>
>> It's definitely QMI capable.
>
> Yes, absolutely.
>
> I just assumed the E371 exists with a Novatel vendor ID as well. Whic=
h
> we could and should also add, if we only knew what the product ID is.
>
> But it wasn't my intention to question the addition of the Dell
> rebranded E371. There's absolutely no need to let that wait. Sorry fo=
r
> being unclear.  I am not communicating well today...
>
>
>
>
> Bj=F8rn
>
