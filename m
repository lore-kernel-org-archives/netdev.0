From: Frans Meulenbroeks <fransmeulenbroeks@gmail.com>
Subject: Re: drivers/net/phy/phy.c issue
Date: Thu, 9 Feb 2012 15:13:27 +0100
Message-ID: <CACW_hTbtdydP1nrjfXZOo83zRfBAXbvvNzo68RO73Y54w5=Bxg@mail.gmail.com>
References: <CACW_hTY41xZV6d0W2Z2kRfKOfa+RSQ-A-BoZsZwNXSQmeF_6Gg@mail.gmail.com>
	<1328729420.2261.329.camel@groeck-laptop>
	<CACW_hTbLd3kbuwJy9U2ZGDi3ypD-+KsecjYhku7jwQgFPaRqhg@mail.gmail.com>
	<20120208150548.32643cmtaxtymzok@67.228.131.195>
	<CACW_hTad_DtwR7FqqOjzvCOzbdj1PcSCEyUpg6d-G5VtDi3wbQ@mail.gmail.com>
	<20120209130625.GA27224@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "guenter@roeck-us.net" <guenter@roeck-us.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"macro@linux-mips.org" <macro@linux-mips.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <guenter.roeck@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33673 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646Ab2BION2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 09:13:28 -0500
In-Reply-To: <20120209130625.GA27224@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/9 Guenter Roeck <guenter.roeck@ericsson.com>:
> On Thu, Feb 09, 2012 at 03:12:01AM -0500, Frans Meulenbroeks wrote:
>> 2012/2/8 =A0<guenter@roeck-us.net>:
>> > Quoting "Frans Meulenbroeks" <fransmeulenbroeks@gmail.com>:
>> >
>>
>> [...]
>> >> Apologies, but I cannot test on a git head kernel.
>> >>
>> >> And wrt the question of Andy in the subsequent reply.
>> >>
>> >> Hw is a Freescale MPC8313. This is a Gianfar. Is that the info yo=
u wanted?
>> >>
>> > This is the MAC. Andy was asking for the PHY chip.
>> >
>> Sorry yes.
>> The mac is a Marvell 88e1111bab
>
> This time you mean the PHY is Marvell 88e1111bab, not the MAC. Looks =
like
> you are getting confused ;).
>

Sorry yes,
The MAC is the Gianfar on the 83813, the PHY is the Marvell.
Guess I wasn't quite awake when I wrote my previous email.
Apologies for the confusion.

=46rans
