From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Bridge extensions to iproute2
Date: Sat, 4 Aug 2012 18:49:45 -0700
Message-ID: <CAHo-OoxJbZu+1cM2R77RQMyqkvXJv+i5mez5_itj7aN6eviuJg@mail.gmail.com>
References: <CAHo-Ooyk_=UYsEtz-y6hupCtMOgKz2DF+j1BOnSsmAfm-5Bkqg@mail.gmail.com>
	<20120710145821.748c00be@nehalam.linuxnetplumber.net>
	<CAHo-OozFCrcx4FpsuNzEV4Cp_4hbVw896utpstYL2qcD1EwCyA@mail.gmail.com>
	<20120801170713.289e078e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:45980 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754009Ab2HEBtq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 21:49:46 -0400
Received: by obbuo13 with SMTP id uo13so3521419obb.19
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 18:49:45 -0700 (PDT)
In-Reply-To: <20120801170713.289e078e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.  Would it make sense to merge bridge-utils / brctl into iproute=
2?

On Wed, Aug 1, 2012 at 5:07 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Tue, 10 Jul 2012 15:01:26 -0700
> Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:
>
>> > I will get back to these. There wasn't a motivation to go fast bec=
ause
>> > there wasn't a user of these. Now with fdb offload support they ar=
e needed.
>>
>> Do you have some semi-ready patches that could be used for test purp=
oses?
>>
>> While it looks like the forwarding database capability is there in t=
he kernel,
>> I can't currently find an interface to turn learning off.
>
> I cleaned it up an put in 3.5.0 just released version.
