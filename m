From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH next 0/4] bonding: winter cleanup
Date: Wed, 22 Feb 2017 14:21:11 -0500
Message-ID: <CAHashqDKFeOjfw3De+P6OmVcV0S-8wtYRtYJ+TnwOZjorL+hqg@mail.gmail.com>
References: <20170222010816.9676-1-mahesh@bandewar.net> <20170221.222942.1325714864738482633.davem@davemloft.net>
 <CAJ3xEMj=8EtUeCPRT+cxVVqKAGHCtVaQ32GV9zvcDGp+WSspuQ@mail.gmail.com> <CAF2d9jg5iTCb+n4KyEGdtgj0a7Gi7jWNXxmtkXda5o-5koavfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>, mahesh@bandewar.net,
        Jay Vosburgh <j.vosburgh@gmail.com>, vfalico@gmail.com,
        nikolay@redhat.com, Eric Dumazet <edumazet@google.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35132 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933883AbdBVT3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 14:29:21 -0500
Received: by mail-qk0-f173.google.com with SMTP id u188so12502378qkc.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 11:29:20 -0800 (PST)
In-Reply-To: <CAF2d9jg5iTCb+n4KyEGdtgj0a7Gi7jWNXxmtkXda5o-5koavfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 2:17 PM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=
=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=
=B0)
<maheshb@google.com> wrote:
> On Tue, Feb 21, 2017 at 8:36 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>
>> On Wed, Feb 22, 2017 at 5:29 AM, David Miller <davem@davemloft.net> wrot=
e:
>> > From: Mahesh Bandewar <mahesh@bandewar.net>
>> > Date: Tue, 21 Feb 2017 17:08:16 -0800
>> >
>> >> Few cleanup patches that I have accumulated over some time now.
>> >
>> > The net-next tree is closed, therefore it is not appropriate to
>> > submit cleanups at this time.
>> >
> Oops, My bad! Well, this will give an opportunity for people to have
> more time with the patch(s) / clean-up-code :p
>
>> > Please wait until after the merge window and the net-next tree
>> > opens back up.
>> >
> Will do so. Thank you.
>>
>> Maybe we should start educating ppl on this by mandating them to come
>> and bring home made cakes to netdev each time they ignore that?
>>
> That's a risky proposal Or! You are assuming that someone who can
> write code can bake "good" cake too :)

Just bring the recipe, so if it happens not to be tasty we can tell
you why.  :-D

>> in our
>> school this is the model for stopping kids and teachers phones to ring
>> during class time. Jamal - there will be more attendees this way :)
>>
>
>> Or.
